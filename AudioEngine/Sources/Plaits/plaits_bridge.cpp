// Plaits C++ bridge — connects Swift to Mutable Instruments Plaits DSP.
// MIT License (Emilie Gillet / Mutable Instruments)

#include "include/plaits_bridge.h"
#include "plaits/dsp/voice.h"
#include "plaits/dsp/dsp.h"

#include <cstring>
#include <cstdlib>

// Internal wrapper holding a Plaits voice and its memory pool.
struct PlaitsVoiceImpl {
    plaits::Voice voice;
    // Plaits engines share a single RAM buffer via BufferAllocator.
    // 32KB is sufficient for all engines.
    char shared_buffer[32768];
};

extern "C" {

PlaitsVoiceHandle plaits_create(void) {
    auto* impl = new PlaitsVoiceImpl();
    memset(impl->shared_buffer, 0, sizeof(impl->shared_buffer));

    stmlib::BufferAllocator allocator;
    allocator.Init(impl->shared_buffer, sizeof(impl->shared_buffer));
    impl->voice.Init(&allocator);

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

    // Set up Plaits patch
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

    // Set up modulations (touch-only, no CV patching)
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

    // Plaits renders in blocks of kBlockSize (12 samples at 48kHz).
    // We process the requested sample_count in kBlockSize chunks.
    const size_t block_size = plaits::kBlockSize;
    plaits::Voice::Frame frames[plaits::kMaxBlockSize];

    int samples_rendered = 0;
    while (samples_rendered < sample_count) {
        // Render one block
        impl->voice.Render(patch, modulations, frames, block_size);

        // After first block, clear trigger so subsequent blocks don't re-trigger
        modulations.trigger = 0.0f;

        // Convert int16 frames to float and write to output
        for (size_t i = 0; i < block_size && samples_rendered < sample_count; i++) {
            out[samples_rendered] = static_cast<float>(frames[i].out) / 32768.0f;
            if (aux) {
                aux[samples_rendered] = static_cast<float>(frames[i].aux) / 32768.0f;
            }
            samples_rendered++;
        }
    }
}

} // extern "C"
