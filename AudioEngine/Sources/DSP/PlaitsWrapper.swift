import Foundation
import PlaitsLib

/// Swift interface to the Plaits C++ DSP engine via the C bridging header.
/// Each instance wraps a single Plaits voice (all 24 models).
public final class PlaitsWrapper {

    private var handle: PlaitsVoiceHandle?

    /// Current trigger state — set to 1.0 on note-on, 0.0 after first render.
    private var triggerValue: Float = 0

    /// Current synth parameters.
    public var model: Int = 0          // 0-23
    public var note: Float = 60.0      // MIDI note (60 = middle C)
    public var harmonics: Float = 0.5  // 0-1
    public var timbre: Float = 0.5     // 0-1
    public var morph: Float = 0.5      // 0-1
    public var decay: Float = 0.5      // LPG decay 0-1
    public var lpgColour: Float = 0.5  // LPG filter colour 0-1

    public init() {
        handle = plaits_create()
    }

    deinit {
        if let h = handle {
            plaits_destroy(h)
        }
    }

    /// Trigger a note-on (sets trigger high for the next render call).
    public func trigger() {
        triggerValue = 1.0
    }

    /// Release the note (clears trigger).
    public func release() {
        triggerValue = 0.0
    }

    /// Set the base frequency from a MIDI note number.
    public func setFrequency(_ freq: Float) {
        // Convert frequency back to MIDI note for Plaits
        // Plaits uses MIDI note internally: note 60 = C4 = 261.63 Hz
        if freq > 0 {
            note = 12.0 * log2f(freq / 440.0) + 69.0
        }
    }

    /// Set the model index (0-23).
    public func setModel(_ model: Int) {
        self.model = min(max(model, 0), 23)
    }

    /// Set the three main parameters (all 0.0-1.0).
    public func setParameters(harmonics: Float, timbre: Float, morph: Float) {
        self.harmonics = harmonics
        self.timbre = timbre
        self.morph = morph
    }

    /// Render a block of audio into the output buffer.
    /// Note: Plaits internally runs at 48kHz. If your audio engine runs at 44.1kHz,
    /// you may want to add sample rate conversion. For now, we render at Plaits'
    /// native rate — the pitch will be slightly sharp (~1.5 cents) at 44.1kHz.
    public func render(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard let h = handle else {
            // No handle — fill silence
            for i in 0..<sampleCount {
                buffer[i] = 0
            }
            return
        }

        plaits_render(
            h,
            Int32(model),
            note,
            harmonics,
            timbre,
            morph,
            triggerValue,
            -1.0,       // level unpatched — use internal envelope
            decay,
            lpgColour,
            buffer,
            nil,        // no aux output needed
            Int32(sampleCount)
        )

        // Clear trigger after first render so we don't re-trigger every block
        if triggerValue > 0 {
            triggerValue = 0
        }
    }

    // MARK: - Model metadata

    /// All 24 Plaits v1.2 model names.
    public static let modelNames: [String] = [
        "Classic Waveforms + Filter", "Phase Distortion",
        "6-Op FM (Bass/Synth)", "6-Op FM (Keys/Pluck/Perc)", "6-Op FM (Organ/Pad/Brass)",
        "Wave Terrain", "String Machine", "Variable Square Chords",
        "Virtual Analog", "Waveshaper", "FM", "Grain / Formant",
        "Harmonic Additive", "Wavetable", "Chord", "Speech / Vowel",
        "Granular Cloud", "Filtered Noise", "Particle Noise", "Inharmonic String",
        "Modal Resonator", "Analog Bass Drum", "Analog Snare Drum", "Analog Hi-Hat",
    ]

    /// Per-model parameter labels for HARMONICS, TIMBRE, MORPH.
    /// Order matches Plaits engine registration order (v1.2 firmware).
    public static let modelParameterLabels: [(harmonics: String, timbre: String, morph: String)] = [
        ("Resonance", "Filter cutoff", "Waveform / sub"),         // 0: VCF
        ("Dist frequency", "Dist amount", "Dist asymmetry"),      // 1: Phase Dist
        ("Preset selection", "Modulator level", "Env time-travel"),// 2: 6-Op A
        ("Preset selection", "Modulator level", "Env time-travel"),// 3: 6-Op B
        ("Preset selection", "Modulator level", "Env time-travel"),// 4: 6-Op C
        ("Terrain select", "Path radius", "Path offset"),         // 5: Wave Terrain
        ("Chord", "Chorus / filter", "Waveform"),                 // 6: String Machine
        ("Chord", "Arp type", "PW / Sync"),                       // 7: Var Square
        ("Detuning / shape", "Pulse width", "Waveshape"),         // 8: Virtual Analog
        ("Waveshape amount", "Fold amount", "Asymmetry"),         // 9: Waveshaper
        ("FM ratio", "FM amount", "Feedback"),                    // 10: FM
        ("Interval", "Formant freq", "Formant width"),            // 11: Grain
        ("Harmonic spread", "Spectral peak", "Bump shape"),       // 12: Additive
        ("Row", "Column", "Interpolation"),                       // 13: Wavetable
        ("Chord type", "Inversion", "Waveform"),                  // 14: Chord
        ("Phoneme", "Formant shift", "Speed"),                    // 15: Speech
        ("Pitch randomize", "Grain density", "Grain duration"),   // 16: Swarm/Granular
        ("Filter type", "Cutoff frequency", "Resonance"),         // 17: Noise
        ("Density", "Filter frequency", "Freq randomize"),        // 18: Particle
        ("Inharmonicity", "Brightness", "Damping"),               // 19: String
        ("Frequency ratio", "Brightness", "Damping"),             // 20: Modal
        ("Decay", "Pitch mod depth", "Tone / click"),             // 21: Bass Drum
        ("Noise amount", "Tone frequency", "Decay"),              // 22: Snare
        ("Tone cluster", "Tone frequency", "Decay"),              // 23: Hi-Hat
    ]
}
