// Plaits C++ bridge — stub implementation.
// Replace with actual Mutable Instruments Plaits DSP code (MIT license).
// Source: https://github.com/pichenettes/eurorack/tree/master/plaits

#include "include/plaits_bridge.h"
#include <cmath>
#include <cstdlib>

// Placeholder voice structure — will be replaced with actual Plaits::Voice
struct PlaitsVoiceImpl {
    float sample_rate;
    int model;
    float frequency;
    float harmonics;
    float timbre;
    float morph;
    bool triggered;
    float phase;
};

extern "C" {

PlaitsVoiceHandle plaits_create(float sample_rate) {
    auto* voice = new PlaitsVoiceImpl();
    voice->sample_rate = sample_rate;
    voice->model = 0;
    voice->frequency = 440.0f;
    voice->harmonics = 0.5f;
    voice->timbre = 0.5f;
    voice->morph = 0.5f;
    voice->triggered = false;
    voice->phase = 0.0f;
    return voice;
}

void plaits_destroy(PlaitsVoiceHandle handle) {
    delete static_cast<PlaitsVoiceImpl*>(handle);
}

void plaits_set_model(PlaitsVoiceHandle handle, int model) {
    static_cast<PlaitsVoiceImpl*>(handle)->model = model;
}

void plaits_set_frequency(PlaitsVoiceHandle handle, float frequency) {
    static_cast<PlaitsVoiceImpl*>(handle)->frequency = frequency;
}

void plaits_set_parameters(PlaitsVoiceHandle handle,
                           float harmonics,
                           float timbre,
                           float morph) {
    auto* v = static_cast<PlaitsVoiceImpl*>(handle);
    v->harmonics = harmonics;
    v->timbre = timbre;
    v->morph = morph;
}

void plaits_set_trigger(PlaitsVoiceHandle handle, int trigger) {
    static_cast<PlaitsVoiceImpl*>(handle)->triggered = (trigger != 0);
}

void plaits_render(PlaitsVoiceHandle handle,
                   float* output,
                   int sample_count) {
    auto* v = static_cast<PlaitsVoiceImpl*>(handle);

    // Placeholder: simple sine oscillator until Plaits DSP is integrated
    float phase_increment = v->frequency / v->sample_rate;
    for (int i = 0; i < sample_count; i++) {
        output[i] = sinf(v->phase * 2.0f * M_PI) * 0.5f;
        v->phase += phase_increment;
        if (v->phase >= 1.0f) v->phase -= 1.0f;
    }
}

} // extern "C"
