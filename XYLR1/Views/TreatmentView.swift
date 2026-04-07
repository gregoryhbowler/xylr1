import SwiftUI

/// Master treatment effects chain view.
struct TreatmentView: View {
    @EnvironmentObject var appState: AppState

    @State private var randomizeAmount: Float = 0.1
    @State private var gateDW: Float = 0
    @State private var glitchDW: Float = 0
    @State private var tremDW: Float = 0
    @State private var wowFltDW: Float = 0
    @State private var stretchDW: Float = 0
    @State private var ringDW: Float = 0
    @State private var rvrsDW: Float = 0
    @State private var eqDW: Float = 0
    @State private var verbDW: Float = 0
    @State private var satDW: Float = 0

    private let randomizeOptions: [(value: Float, label: String)] = [
        (0.05, "5%"), (0.10, "10%"), (0.25, "25%"), (0.50, "50%")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: XTheme.controlSpacing) {
            // Header
            HStack {
                Text("LAYER \(appState.activeLayerIndex + 1) TREATMENT")
                    .font(XTheme.headlineFont)
                    .foregroundColor(XTheme.primary)
                Spacer()
                backButton
            }
            .padding(.horizontal, XTheme.viewPadding)
            .padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: XTheme.controlSpacing) {
                    XSegment(
                        label: "RANDOMIZE",
                        options: randomizeOptions.map { ($0.value, $0.label) },
                        selected: $randomizeAmount
                    )

                    EffectRow(name: "GATE", dryWet: $gateDW)
                    EffectRow(name: "GLITCH", dryWet: $glitchDW)
                    EffectRow(name: "TREM", dryWet: $tremDW)
                    EffectRow(name: "WOW/FLT", dryWet: $wowFltDW)
                    EffectRow(name: "STRETCH", dryWet: $stretchDW)
                    EffectRow(name: "RING", dryWet: $ringDW)
                    EffectRow(name: "RVRS", dryWet: $rvrsDW)
                    EffectRow(name: "EQ", dryWet: $eqDW)
                    EffectRow(name: "VERB", dryWet: $verbDW)
                    EffectRow(name: "SAT", dryWet: $satDW)
                }
                .padding(.horizontal, XTheme.viewPadding)
            }

            Spacer()

            // Undo
            HStack {
                Spacer()
                XButton(title: "UNDO", style: .filled) { appState.undo() }
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
