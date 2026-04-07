import SwiftUI

/// Delay effect editor — Mimeoclon-style delay per layer.
struct DelayView: View {
    @EnvironmentObject var appState: AppState

    @State private var range: Int = 2           // A=0, B=1, C=2, D=3
    @State private var rate: Float = 12
    @State private var modAmt: Float = 0
    @State private var modFreq: Float = 0
    @State private var stereo: Float = 50
    @State private var repeats: Float = 40
    @State private var tone: Float = 50
    @State private var glow: Float = 0
    @State private var mix: Float = 0

    var body: some View {
        VStack(alignment: .leading, spacing: XTheme.controlSpacing) {
            // Header
            HStack {
                Text("DELAY")
                    .font(XTheme.titleFont)
                    .foregroundColor(XTheme.primary)
                Spacer()
                backButton
            }
            .padding(.horizontal, XTheme.viewPadding)
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: XTheme.controlSpacing) {
                XSegment(
                    label: "RANGE",
                    options: [(0, "A"), (1, "B"), (2, "C"), (3, "D")],
                    selected: $range
                )

                XSlider(label: "RATE", value: $rate,
                        range: 1...24, step: 1, minLabel: "1", maxLabel: "24")
                XSlider(label: "MOD AMT", value: $modAmt,
                        range: 0...100, minLabel: "0", maxLabel: "100")
                XSlider(label: "MOD FREQ", value: $modFreq,
                        range: 0...100, minLabel: "0", maxLabel: "100")
                XSlider(label: "STEREO", value: $stereo,
                        range: 0...100, minLabel: "L", maxLabel: "R")
                XSlider(label: "REPEATS", value: $repeats,
                        range: 0...120, minLabel: "0%", maxLabel: "120%")
                XSlider(label: "TONE", value: $tone,
                        range: 0...100, minLabel: "0", maxLabel: "100")
                XSlider(label: "GLOW", value: $glow,
                        range: 0...100, minLabel: "0", maxLabel: "100")
                XSlider(label: "MIX", value: $mix,
                        range: 0...100, minLabel: "0%", maxLabel: "100%")
            }
            .padding(.horizontal, XTheme.viewPadding)

            Spacer()
        }
        .background(XTheme.background)
    }

    private var backButton: some View {
        Button {
            appState.currentView = .animation
        } label: {
            Text("<")
                .font(XTheme.titleFont)
                .foregroundColor(XTheme.primary)
        }
        .buttonStyle(.plain)
    }
}
