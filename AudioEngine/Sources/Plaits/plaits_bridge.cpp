// Plaits C++ bridge — connects Swift to Mutable Instruments Plaits DSP.
// MIT License (Emilie Gillet / Mutable Instruments)

#include "include/plaits_bridge.h"
#include "plaits/dsp/voice.h"
#include "plaits/dsp/dsp.h"

#include <cstring>
#include <cstdlib>
#include <cmath>

// ---------------------------------------------------------------------------
// Sample rate converter: 48kHz (Plaits native) → 44.1kHz (iOS audio)
// Uses windowed-sinc interpolation (quality comparable to SoX "high" preset).
// ---------------------------------------------------------------------------

static constexpr float kSourceRate = 48000.0f;
static constexpr float kTargetRate = 44100.0f;
static constexpr float kRatio = kTargetRate / kSourceRate;  // 0.91875

// Half the number of taps on each side of the sinc centre. 16 taps total
// gives ~100 dB stopband rejection with a Kaiser window — more than enough
// for 16-bit Plaits output.
static constexpr int kSincHalfTaps = 8;
static constexpr int kSincTaps = kSincHalfTaps * 2;

// Pre-computed Kaiser window beta for ~100 dB attenuation.
static constexpr float kKaiserBeta = 10.0f;

static float bessel_i0(float x) {
    // Modified Bessel function I0 via series expansion (sufficient precision).
    float sum = 1.0f;
    float term = 1.0f;
    for (int k = 1; k < 20; k++) {
        term *= (x * x) / (4.0f * float(k) * float(k));
        sum += term;
        if (term < 1e-8f) break;
    }
    return sum;
}

static float kaiser_window(float n, float N, float beta) {
    float a = 2.0f * n / (N - 1.0f) - 1.0f;
    return bessel_i0(beta * sqrtf(1.0f - a * a)) / bessel_i0(beta);
}

static float sinc(float x) {
    if (fabsf(x) < 1e-6f) return 1.0f;
    float px = float(M_PI) * x;
    return sinf(px) / px;
}

struct SampleRateConverter {
    // Ring buffer holding recent 48kHz samples for the sinc interpolator.
    float history[kSincTaps];
    int write_pos;
    // Fractional position tracking: how far we are between 48kHz samples.
    double phase;

    void Init() {
        memset(history, 0, sizeof(history));
        write_pos = 0;
        phase = 0.0;
    }

    // Push one 48kHz sample into the history.
    void Push(float sample) {
        history[write_pos] = sample;
        write_pos = (write_pos + 1) % kSincTaps;
    }

    // Read an interpolated sample at the current fractional position.
    float Interpolate() const {
        float sum = 0.0f;
        for (int i = 0; i < kSincTaps; i++) {
            // Distance from the interpolation point to this tap.
            float tap_offset = float(i - kSincHalfTaps) + (1.0f - float(phase));
            float coeff = sinc(tap_offset) *
                          kaiser_window(float(i), float(kSincTaps), kKaiserBeta);
            int idx = (write_pos - kSincTaps + i + kSincTaps * 2) % kSincTaps;
            sum += history[idx] * coeff;
        }
        return sum;
    }
};

// ---------------------------------------------------------------------------
// Plaits voice wrapper
// ---------------------------------------------------------------------------

// Maximum samples we'd ever render in one call (128 at 44.1kHz needs
// ceil(128 / 0.91875) ≈ 140 source samples, round up to multiple of 12).
static constexpr int kMaxSourceSamples = 256;

struct PlaitsVoiceImpl {
    plaits::Voice voice;
    // Plaits engines share a single RAM buffer via BufferAllocator.
    char shared_buffer[32768];

    // Per-channel sample rate converters.
    SampleRateConverter src_out;
    SampleRateConverter src_aux;
};

extern "C" {

PlaitsVoiceHandle plaits_create(void) {
    auto* impl = new PlaitsVoiceImpl();
    memset(impl->shared_buffer, 0, sizeof(impl->shared_buffer));

    stmlib::BufferAllocator allocator;
    allocator.Init(impl->shared_buffer, sizeof(impl->shared_buffer));
    impl->voice.Init(&allocator);

    impl->src_out.Init();
    impl->src_aux.Init();

    return impl;
}

void plaits_destroy(PlaitsVoiceHandle handle) {
    delete static_cast<PlaitsVoiceImpl*>(handle);
}

void plaits_render(PlaitsVoiceHandle handle,
                   int engine,
                   float note,
                   float harmonics,
                   float timbre,
                   float morph,
                   float trigger,
                   float level,
                   float decay,
                   float lpg_colour,
                   float* out,
                   float* aux,
                   int sample_count) {
    auto* impl = static_cast<PlaitsVoiceImpl*>(handle);

    // --- Set up Plaits patch ---
    plaits::Patch patch;
    patch.engine = engine;
    patch.note = note;
    patch.harmonics = harmonics;
    patch.timbre = timbre;
    patch.morph = morph;
    patch.frequency_modulation_amount = 0.0f;
    patch.timbre_modulation_amount = 0.0f;
    patch.morph_modulation_amount = 0.0f;
    patch.decay = decay;
    patch.lpg_colour = lpg_colour;

    // --- Set up modulations (touch-only, no CV patching) ---
    plaits::Modulations modulations;
    modulations.engine = 0.0f;
    modulations.note = 0.0f;
    modulations.frequency = 0.0f;
    modulations.harmonics = 0.0f;
    modulations.timbre = 0.0f;
    modulations.morph = 0.0f;
    modulations.trigger = trigger;
    modulations.level = level;
    modulations.frequency_patched = false;
    modulations.timbre_patched = false;
    modulations.morph_patched = false;
    modulations.trigger_patched = (trigger > 0.0f);
    modulations.level_patched = (level >= 0.0f);

    // --- Render at 48kHz and resample to 44.1kHz ---
    //
    // For each 44.1kHz output sample we advance a fractional position through
    // the 48kHz source stream. When the integer part advances we render more
    // Plaits blocks as needed.
    //
    // Step per output sample in source-sample units:
    const double step = double(kSourceRate) / double(kTargetRate); // ~1.08844

    const size_t block_size = plaits::kBlockSize;
    plaits::Voice::Frame frames[plaits::kMaxBlockSize];

    // Source samples available in the current Plaits block.
    int src_available = 0;
    int src_index = 0;

    for (int i = 0; i < sample_count; i++) {
        // Advance fractional phase
        impl->src_out.phase += step;

        // Feed source samples into the SRC history until we've caught up.
        while (impl->src_out.phase >= 1.0) {
            impl->src_out.phase -= 1.0;
            impl->src_aux.phase = impl->src_out.phase;

            // Need another source sample — render a new block if exhausted.
            if (src_index >= src_available) {
                impl->voice.Render(patch, modulations, frames, block_size);
                // Clear trigger after first block.
                modulations.trigger = 0.0f;
                src_available = static_cast<int>(block_size);
                src_index = 0;
            }

            float s_out = static_cast<float>(frames[src_index].out) / 32768.0f;
            float s_aux = static_cast<float>(frames[src_index].aux) / 32768.0f;
            impl->src_out.Push(s_out);
            impl->src_aux.Push(s_aux);
            src_index++;
        }

        // Interpolate at the fractional position.
        out[i] = impl->src_out.Interpolate();
        if (aux) {
            aux[i] = impl->src_aux.Interpolate();
        }
    }
}

} // extern "C"
