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

/// Plaits model parameter labels — extracted for reuse.
enum PlaitsModelLabels {
    static let labels: [(harmonics: String, timbre: String, morph: String)] = [
        ("Detuning", "Pulse width", "Waveshape"),
        ("Waveshape", "Fold", "Asymmetry"),
        ("FM ratio", "FM amount", "Feedback"),
        ("Interval", "Formant freq", "Formant width"),
        ("Harm spread", "Spectral peak", "Bump shape"),
        ("Row", "Column", "Interpolation"),
        ("Chord type", "Inversion", "Waveform"),
        ("Phoneme", "Formant shift", "Speed"),
        ("Pitch rand", "Grain density", "Grain dur"),
        ("Filter type", "Cutoff freq", "Resonance"),
        ("Density", "Filter freq", "Freq random"),
        ("Inharm", "Brightness", "Damping"),
        ("Freq ratio", "Brightness", "Damping"),
        ("Decay", "Pitch mod", "Tone/click"),
        ("Noise amt", "Tone freq", "Decay"),
        ("Tone cluster", "Tone freq", "Decay"),
        ("Resonance", "Filter cut", "Wave/sub"),
        ("Dist freq", "Dist amount", "Dist asym"),
        ("Preset sel", "Mod level", "Env travel"),
        ("Preset sel", "Mod level", "Env travel"),
        ("Preset sel", "Mod level", "Env travel"),
        ("Terrain", "Path radius", "Path offset"),
        ("Chord", "Chorus/flt", "Waveform"),
        ("Chord", "Arp type", "PW/Sync"),
    ]
}
