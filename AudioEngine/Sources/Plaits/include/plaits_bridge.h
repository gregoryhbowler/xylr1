#ifndef PLAITS_BRIDGE_H
#define PLAITS_BRIDGE_H

#ifdef __cplusplus
extern "C" {
#endif

/// Opaque handle to a Plaits voice instance.
typedef void* PlaitsVoiceHandle;

/// Create a new Plaits voice. Call once per voice.
/// The voice runs at Plaits' native 48kHz sample rate internally.
PlaitsVoiceHandle plaits_create(void);

/// Destroy a Plaits voice and free its memory.
void plaits_destroy(PlaitsVoiceHandle handle);

/// Render a block of audio.
///
/// Parameters:
///   handle       - Voice handle from plaits_create()
///   engine       - Synthesis model index (0-23)
///   note         - MIDI-style note number (e.g., 60.0 = middle C)
///   harmonics    - HARMONICS parameter (0.0 - 1.0)
///   timbre       - TIMBRE parameter (0.0 - 1.0)
///   morph        - MORPH parameter (0.0 - 1.0)
///   trigger      - 1.0 for note-on trigger, 0.0 for sustain/release
///   level        - Amplitude level (0.0 - 1.0), or -1.0 for unpatched
///   decay        - LPG decay (0.0 - 1.0)
///   lpg_colour   - LPG colour / filter (0.0 - 1.0)
///   out          - Output buffer (float, at least sample_count elements)
///   aux          - Auxiliary output buffer (float, at least sample_count), or NULL
///   sample_count - Number of samples to render (will be processed in blocks of 12)
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
                   int sample_count);

#ifdef __cplusplus
}
#endif

#endif /* PLAITS_BRIDGE_H */
