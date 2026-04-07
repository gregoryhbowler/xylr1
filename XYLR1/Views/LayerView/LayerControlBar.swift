import SwiftUI

/// Bottom control bar for the layer view — groups, loop controls, navigation buttons.
struct LayerControlBar: View {
    @EnvironmentObject var appState: AppState
    @Binding var layer: LayerState

    var body: some View {
        VStack(spacing: 8) {
            // Groups + Loop row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("GROUP")
                        .font(XTheme.valueFont)
                        .foregroundColor(XTheme.primary)
                    XToggleGrid(count: 8, activeIndices: $layer.activeGroups)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("LOOP")
                        .font(XTheme.valueFont)
                        .foregroundColor(XTheme.primary)
                    HStack(spacing: 4) {
                        XButton(title: "REC") {
                            appState.masterTransport.mode = .recording
                        }
                        XButton(title: "PLAY") {
                            appState.masterTransport.mode = .playing
                        }
                        XButton(title: "PAUSE") {
                            appState.masterTransport.mode = .paused
                        }
                    }
                }
            }

            // Navigation row
            HStack(spacing: 4) {
                XButton(title: "ANIMATION") {
                    appState.currentView = .animation
                }
                XButton(title: "ENVIRONMENT") {
                    appState.currentView = .environment
                }
                XButton(title: "TREATMENT") {
                    appState.currentView = .treatment
                }
            }

            HStack(spacing: 4) {
                XButton(title: "RANDOMIZE") {
                    layer.generateGlyphs()
                }
                XButton(title: "PATCH") {
                    randomizePatch()
                }
                XButton(title: "NOTES") {
                    layer.generateGlyphs()
                }
                XButton(title: "MOD") {
                    // Randomize LFO parameters
                }
                XButton(title: "UNDO", style: .filled) {
                    if let snapshot = layer.undoSnapshot {
                        layer = snapshot
                    }
                }
            }
        }
    }

    private func randomizePatch() {
        layer.undoSnapshot = layer
        layer.model = Int.random(in: 1...24)
        layer.harmonics = Float.random(in: 0...1)
        layer.timbre = Float.random(in: 0...1)
        layer.morph = Float.random(in: 0...1)
        layer.cutoff = Float.random(in: 200...20000)
        layer.resonance = Float.random(in: 0...1)
        layer.attackTime = Float.random(in: 0.001...2)
        layer.decayTime = Float.random(in: 0.01...3)
        layer.sustainLevel = Float.random(in: 0...1)
        layer.releaseTime = Float.random(in: 0.01...4)
    }
}
