import Foundation

/// Swift interface to the Plaits C++ DSP engine via the C bridging header.
/// This wraps a single Plaits "voice" processor.
public final class PlaitsWrapper {

    /// All 24 Plaits v1.2 model names.
    public static let modelNames: [String] = [
        "Virtual Analog", "Waveshaper", "FM", "Grain / Formant",
        "Harmonic Additive", "Wavetable", "Chord", "Speech / Vowel",
        "Granular Cloud", "Filtered Noise", "Particle Noise", "Inharmonic String",
        "Modal Resonator", "Analog Bass Drum", "Analog Snare Drum", "Analog Hi-Hat",
        "Classic Waveforms + Filter", "Phase Distortion",
        "6-Op FM (Bass/Synth)", "6-Op FM (Keys/Pluck/Perc)", "6-Op FM (Organ/Pad/Brass)",
        "Wave Terrain", "String Machine", "Variable Square Chords"
    ]

    /// Per-model parameter labels for HARMONICS, TIMBRE, MORPH.
    public static let modelParameterLabels: [(harmonics: String, timbre: String, morph: String)] = [
        ("Detuning / shape", "Pulse width", "Waveshape"),
        ("Waveshape amount", "Fold amount", "Asymmetry"),
        ("FM ratio", "FM amount", "Feedback"),
        ("Interval", "Formant freq", "Formant width"),
        ("Harmonic spread", "Spectral peak", "Bump shape"),
        ("Row", "Column", "Interpolation"),
        ("Chord type", "Inversion", "Waveform"),
        ("Phoneme", "Formant shift", "Speed"),
        ("Pitch randomize", "Grain density", "Grain duration"),
        ("Filter type", "Cutoff frequency", "Resonance"),
        ("Density", "Filter frequency", "Freq randomize"),
        ("Inharmonicity", "Brightness", "Damping"),
        ("Frequency ratio", "Brightness", "Damping"),
        ("Decay", "Pitch mod depth", "Tone / click"),
        ("Noise amount", "Tone frequency", "Decay"),
        ("Tone cluster", "Tone frequency", "Decay"),
        ("Resonance", "Filter cutoff", "Waveform / sub"),
        ("Dist frequency", "Dist amount", "Dist asymmetry"),
        ("Preset selection", "Modulator level", "Env time-travel"),
        ("Preset selection", "Modulator level", "Env time-travel"),
        ("Preset selection", "Modulator level", "Env time-travel"),
        ("Terrain select", "Path radius", "Path offset"),
        ("Chord", "Chorus / filter", "Waveform"),
        ("Chord", "Arp type", "PW / Sync"),
    ]

    // Placeholder — actual implementation will call into the C++ bridge
    private var model: Int = 0
    private var frequency: Float = 440.0
    private var harmonics: Float = 0.5
    private var timbre: Float = 0.5
    private var morph: Float = 0.5

    public init() {}

    public func setModel(_ model: Int) {
        self.model = min(max(model - 1, 0), 23)
    }

    public func setFrequency(_ freq: Float) {
        self.frequency = freq
    }

    public func setParameters(harmonics: Float, timbre: Float, morph: Float) {
        self.harmonics = harmonics
        self.timbre = timbre
        self.morph = morph
    }

    /// Render a block of audio. Placeholder — will call plaits_render() via bridge.
    public func render(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        // Placeholder: generate silence until C++ bridge is connected
        for i in 0..<sampleCount {
            buffer[i] = 0
        }
    }
}
