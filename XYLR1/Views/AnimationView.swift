import SwiftUI

/// Arpeggiator / animation parameters view.
struct AnimationView: View {
    @EnvironmentObject var appState: AppState

    @State private var randomizeAmount: Float = 0.1
    @State private var arpRate: Float = 50
    @State private var randomOct: Float = 0
    @State private var randomNote: Float = 0
    @State private var pathValue: Float = 0
    @State private var delaySyncMode: Int = 0  // 0=SYNC, 1=FREE
    @State private var delayTime: Float = 50
    @State private var delayFeedback: Float = 0
    @State private var delayDryWet: Float = 0
    @State private var delayModulation: Float = 0
    @State private var quantizeMidi: Float = 50
    @State private var playbackRate: Float = 50
    @State private var swing: Float = 0
    @State private var ratchet: Float = 0

    // Animation FX dry/wet values
    @State private var phaserDW: Float = 0
    @State private var flangerDW: Float = 0
    @State private var chorusDW: Float = 0
    @State private var tremoloDW: Float = 0

    private let randomizeOptions: [(value: Float, label: String)] = [
        (0.05, "5%"), (0.10, "10%"), (0.25, "25%"), (0.50, "50%")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("LAYER \(appState.activeLayerIndex + 1) ANIMATION")
                    .font(XTheme.headlineFont)
                    .foregroundColor(XTheme.primary)
                Spacer()
                backButton
            }
            .padding(.horizontal, XTheme.viewPadding)
            .padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: XTheme.controlSpacing) {
                    // Randomize
                    XSegment(
                        label: "RANDOMIZE",
                        options: randomizeOptions.map { ($0.value, $0.label) },
                        selected: $randomizeAmount
                    )

                    // Arp parameters
                    XSlider(label: "RATE (SYNC?)", value: $arpRate,
                            range: 0...100, minLabel: "1/64", maxLabel: "8/8")
                    XSlider(label: "RANDOM OCT", value: $randomOct,
                            range: 0...100, minLabel: "0%", maxLabel: "100%")
                    XSlider(label: "RANDOM NOTE", value: $randomNote,
                            range: 0...100, minLabel: "0%", maxLabel: "100%")
                    XSlider(label: "PATH", value: $pathValue,
                            range: 0...8, step: 1, minLabel: "0", maxLabel: "8")

                    // Delay section
                    HStack {
                        Button {
                            appState.currentView = .delay
                        } label: {
                            Text("DELAY")
                                .font(XTheme.labelFont)
                                .foregroundColor(XTheme.primary)
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        XSegment(
                            label: "",
                            options: [(0, "SYNC"), (1, "FREE")],
                            selected: $delaySyncMode
                        )
                    }

                    XSlider(label: "TIME", value: $delayTime,
                            range: 0...100, minLabel: "1/64", maxLabel: "4/4")
                    XSlider(label: "FEEDBACK", value: $delayFeedback,
                            range: 0...100, minLabel: "0%", maxLabel: "100%")
                    XSlider(label: "DRY/WET", value: $delayDryWet,
                            range: 0...100, minLabel: "0%", maxLabel: "100%")
                    XSlider(label: "MODULATION", value: $delayModulation,
                            range: 0...100, minLabel: "0%", maxLabel: "100%")

                    // Synth section (condensed)
                    Text("SYNTH")
                        .font(XTheme.labelFont)
                        .foregroundColor(XTheme.primary)

                    let layer = Binding(
                        get: { appState.activeLayer },
                        set: { appState.layers[appState.activeLayerIndex] = $0 }
                    )

                    XSlider(label: "MODEL", value: Binding(
                        get: { Float(layer.wrappedValue.model) },
                        set: { layer.wrappedValue.model = Int($0) }
                    ), range: 1...16, step: 1, minLabel: "1", maxLabel: "16")

                    XSlider(label: "AMP ATT", value: layer.attackTime,
                            range: 0...4000, minLabel: "0MS", maxLabel: "4S")
                    XSlider(label: "AMP SUS", value: layer.sustainLevel,
                            range: 0...100, minLabel: "0MS", maxLabel: "5S")
                    XSlider(label: "AMP REL", value: layer.releaseTime,
                            range: 0...4000, minLabel: "0MS", maxLabel: "4S")

                    XSlider(label: "QUANTIZE", value: $quantizeMidi,
                            range: 0...100, minLabel: "1/64", maxLabel: "1/1")
                    XSlider(label: "PLAY RATE", value: $playbackRate,
                            range: 0...100, minLabel: "1/4", maxLabel: "8/8")
                    XSlider(label: "SWING", value: $swing,
                            range: 0...100, minLabel: "0%", maxLabel: "100%")
                    XSlider(label: "RATCHET", value: $ratchet,
                            range: 0...16, step: 1, minLabel: "0", maxLabel: "16")

                    // Animation FX
                    Text("RANDOMIZE")
                        .font(XTheme.labelFont)
                        .foregroundColor(XTheme.primary)

                    EffectRow(name: "PHASER", dryWet: $phaserDW)
                    EffectRow(name: "FLANGER", dryWet: $flangerDW)
                    EffectRow(name: "CHORUS", dryWet: $chorusDW)
                    EffectRow(name: "TREMOLO", dryWet: $tremoloDW)

                    // Undo
                    HStack {
                        Spacer()
                        XButton(title: "UNDO", style: .filled) {
                            // Undo last randomization
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, XTheme.viewPadding)
                .padding(.bottom, 16)
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

/// Reusable effect row with >> randomize and D/W controls.
struct EffectRow: View {
    let name: String
    @Binding var dryWet: Float
    var onRandomize: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            Text(name)
                .font(XTheme.labelFont)
                .foregroundColor(XTheme.primary)
                .frame(width: 60, alignment: .leading)

            Button {
                onRandomize?()
            } label: {
                Text(">>")
                    .font(XTheme.valueFont)
                    .foregroundColor(XTheme.primary)
            }
            .buttonStyle(.plain)

            Button {
                // Toggle D/W display
            } label: {
                Text("D/W")
                    .font(XTheme.valueFont)
                    .foregroundColor(XTheme.primary)
            }
            .buttonStyle(.plain)

            XSlider(label: "", value: $dryWet, range: 0...100,
                    minLabel: "0%", maxLabel: "100%")
        }
    }
}
