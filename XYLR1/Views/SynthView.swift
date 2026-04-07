import SwiftUI

/// Synth parameter editor view.
struct SynthView: View {
    @EnvironmentObject var appState: AppState

    @State private var randomizeAmount: Float = 0.1

    private let randomizeOptions: [(value: Float, label: String)] = [
        (0.05, "5%"), (0.10, "10%"), (0.25, "25%"), (0.50, "50%")
    ]

    private var layer: Binding<LayerState> {
        Binding(
            get: { appState.activeLayer },
            set: { appState.layers[appState.activeLayerIndex] = $0 }
        )
    }

    /// Per-model parameter labels for the three main controls.
    private var modelLabels: (harmonics: String, timbre: String, morph: String) {
        let idx = max(0, min(23, layer.wrappedValue.model - 1))
        return PlaitsModelLabels.labels[idx]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: XTheme.controlSpacing) {
            // Header
            HStack {
                Text("SYNTH")
                    .font(XTheme.titleFont)
                    .foregroundColor(XTheme.primary)
                Spacer()
                backButton
            }
            .padding(.horizontal, XTheme.viewPadding)

            ScrollView {
                VStack(alignment: .leading, spacing: XTheme.controlSpacing) {
                    // Randomize
                    XSegment(
                        label: "RANDOMIZE",
                        options: randomizeOptions.map { ($0.value, $0.label) },
                        selected: $randomizeAmount
                    )

                    // Model
                    XSlider(
                        label: "MODEL",
                        value: Binding(
                            get: { Float(layer.wrappedValue.model) },
                            set: { layer.wrappedValue.model = max(1, min(24, Int($0))) }
                        ),
                        range: 1...24,
                        step: 1,
                        minLabel: "1",
                        maxLabel: "24"
                    )

                    // Frequency (display only — set by note tap)
                    XSlider(label: "FREQUENCY", value: .constant(50), range: 0...100,
                            minLabel: "0", maxLabel: "100")

                    // Harmonics (model-specific label)
                    XSlider(
                        label: modelLabels.harmonics.prefix(12).uppercased(),
                        value: layer.harmonics,
                        range: 0...100,
                        minLabel: "0", maxLabel: "100"
                    )

                    // Timbre (model-specific label)
                    XSlider(
                        label: modelLabels.timbre.prefix(12).uppercased(),
                        value: layer.timbre,
                        range: 0...100,
                        minLabel: "0", maxLabel: "100"
                    )

                    // Morph (model-specific label)
                    XSlider(
                        label: modelLabels.morph.prefix(12).uppercased(),
                        value: layer.morph,
                        range: 0...100,
                        minLabel: "0", maxLabel: "100"
                    )

                    // Filter
                    XSlider(label: "CUTOFF", value: layer.cutoff,
                            range: 20...20000, minLabel: "20", maxLabel: "20K")

                    XSlider(label: "RESONANCE", value: layer.resonance,
                            range: 0...100, minLabel: "0", maxLabel: "100")

                    // ADSR
                    XSlider(label: "ATT", value: layer.attackTime,
                            range: 0...4000, minLabel: "0MS", maxLabel: "4S")

                    XSlider(label: "DEC", value: layer.decayTime,
                            range: 0...5000, minLabel: "0MS", maxLabel: "5S")

                    XSlider(label: "SUS", value: layer.sustainLevel,
                            range: 0...100, minLabel: "0%", maxLabel: "100%")

                    XSlider(label: "REL", value: layer.releaseTime,
                            range: 0...4000, minLabel: "0MS", maxLabel: "4S")
                }
                .padding(.horizontal, XTheme.viewPadding)
            }
        }
        .background(XTheme.background)
    }

    private var backButton: some View {
        Button {
            appState.currentView = .layer
        } label: {
            Text("<")
                .font(XTheme.titleFont)
                .foregroundColor(XTheme.primary)
        }
        .buttonStyle(.plain)
    }
}

/// Plaits model parameter labels — matches engine registration order in voice.cc.
/// Models 1-8 = v1.2 "orange bank", 9-24 = original engines.
enum PlaitsModelLabels {
    static let labels: [(harmonics: String, timbre: String, morph: String)] = [
        ("Resonance", "Filter cut", "Wave/sub"),       //  1: Classic WF + Filter
        ("Dist freq", "Dist amount", "Dist asym"),      //  2: Phase Distortion
        ("Preset sel", "Mod level", "Env travel"),      //  3: 6-Op FM (A)
        ("Preset sel", "Mod level", "Env travel"),      //  4: 6-Op FM (B)
        ("Preset sel", "Mod level", "Env travel"),      //  5: 6-Op FM (C)
        ("Terrain", "Path radius", "Path offset"),      //  6: Wave Terrain
        ("Chord", "Chorus/flt", "Waveform"),            //  7: String Machine
        ("Chord", "Arp type", "PW/Sync"),               //  8: Var Square Chords
        ("Detuning", "Pulse width", "Waveshape"),       //  9: Virtual Analog
        ("Waveshape", "Fold", "Asymmetry"),             // 10: Waveshaper
        ("FM ratio", "FM amount", "Feedback"),          // 11: FM
        ("Interval", "Formant freq", "Formant width"),  // 12: Grain / Formant
        ("Harm spread", "Spectral peak", "Bump shape"), // 13: Harmonic Additive
        ("Row", "Column", "Interpolation"),             // 14: Wavetable
        ("Chord type", "Inversion", "Waveform"),        // 15: Chord
        ("Phoneme", "Formant shift", "Speed"),          // 16: Speech / Vowel
        ("Pitch rand", "Grain density", "Grain dur"),   // 17: Granular Cloud
        ("Filter type", "Cutoff freq", "Resonance"),    // 18: Filtered Noise
        ("Density", "Filter freq", "Freq random"),      // 19: Particle Noise
        ("Inharm", "Brightness", "Damping"),            // 20: Inharmonic String
        ("Freq ratio", "Brightness", "Damping"),        // 21: Modal Resonator
        ("Decay", "Pitch mod", "Tone/click"),           // 22: Analog Bass Drum
        ("Noise amt", "Tone freq", "Decay"),            // 23: Analog Snare Drum
        ("Tone cluster", "Tone freq", "Decay"),         // 24: Analog Hi-Hat
    ]
}
