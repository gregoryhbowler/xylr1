import SwiftUI

/// Per-layer environment effects chain view.
struct EnvironmentView: View {
    @EnvironmentObject var appState: AppState

    @State private var randomizeAmount: Float = 0.1
    @State private var resoDW: Float = 0
    @State private var harmDW: Float = 0
    @State private var freqDW: Float = 0
    @State private var fuzzDW: Float = 0
    @State private var distDW: Float = 0
    @State private var grainDW: Float = 0

    private let randomizeOptions: [(value: Float, label: String)] = [
        (0.05, "5%"), (0.10, "10%"), (0.25, "25%"), (0.50, "50%")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: XTheme.controlSpacing) {
            // Header
            HStack {
                Text("LAYER \(appState.activeLayerIndex + 1) ENVIRONMENT")
                    .font(XTheme.headlineFont)
                    .foregroundColor(XTheme.primary)
                Spacer()
                backButton
            }
            .padding(.horizontal, XTheme.viewPadding)
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: XTheme.controlSpacing) {
                XSegment(
                    label: "RANDOMIZE",
                    options: randomizeOptions.map { ($0.value, $0.label) },
                    selected: $randomizeAmount
                )

                EffectRow(name: "RESO", dryWet: $resoDW)
                EffectRow(name: "HARM", dryWet: $harmDW)
                EffectRow(name: "FREQ", dryWet: $freqDW)
                EffectRow(name: "FUZZ", dryWet: $fuzzDW)
                EffectRow(name: "DIST", dryWet: $distDW)
                EffectRow(name: "GRAIN", dryWet: $grainDW)
            }
            .padding(.horizontal, XTheme.viewPadding)

            Spacer()

            // Undo
            HStack {
                Spacer()
                XButton(title: "UNDO", style: .filled) {}
                Spacer()
            }
            .padding(.bottom, 16)
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
