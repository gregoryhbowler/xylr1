#ifndef PLAITS_BRIDGE_H
#define PLAITS_BRIDGE_H

#ifdef __cplusplus
extern "C" {
#endif

/// Opaque handle to a Plaits voice instance.
typedef void* PlaitsVoiceHandle;

/// Create a new Plaits voice. Returns a handle.
PlaitsVoiceHandle plaits_create(float sample_rate);

/// Destroy a Plaits voice.
void plaits_destroy(PlaitsVoiceHandle handle);

/// Set the synthesis model (0-23).
void plaits_set_model(PlaitsVoiceHandle handle, int model);

/// Set the base frequency in Hz.
void plaits_set_frequency(PlaitsVoiceHandle handle, float frequency);

/// Set the three main parameters (all 0.0-1.0).
void plaits_set_parameters(PlaitsVoiceHandle handle,
                           float harmonics,
                           float timbre,
                           float morph);

/// Set the trigger state (gate on/off).
void plaits_set_trigger(PlaitsVoiceHandle handle, int trigger);

/// Render a block of audio into the output buffer.
/// output must point to at least sample_count floats.
void plaits_render(PlaitsVoiceHandle handle,
                   float* output,
                   int sample_count);

#ifdef __cplusplus
}
#endif

#endif /* PLAITS_BRIDGE_H */
