import SwiftUI
import AudioEngine

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
                    appState.saveUndoSnapshot()
                    layer.generateGlyphs()
                }
                XButton(title: "PATCH") {
                    randomizePatch()
                }
                XButton(title: "NOTES") {
                    appState.saveUndoSnapshot()
                    layer.generateGlyphs()
                }
                XButton(title: "MOD") {
                    randomizeMod()
                }
                XButton(title: "UNDO", style: .filled) {
                    appState.undo()
                }
            }
        }
    }

    private func randomizePatch() {
        appState.saveUndoSnapshot()
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
        appState.syncSynthParams()
    }

    private func randomizeMod() {
        appState.saveUndoSnapshot()
        // Randomize LFO parameters for current layer
        guard appState.activeLayerIndex < appState.audioEngine.layers.count else { return }
        let engine = appState.audioEngine.layers[appState.activeLayerIndex]
        engine.lfo1.shape = LFOShape.allCases.randomElement()!
        engine.lfo1.destination1 = LFODestination.allCases.randomElement()!
        engine.lfo1.destination2 = LFODestination.allCases.randomElement()!
        engine.lfo1.amount1 = Float.random(in: 0...1)
        engine.lfo1.amount2 = Float.random(in: 0...1)
        engine.lfo1.rate = Float.random(in: 0.1...10)
        engine.lfo2.shape = LFOShape.allCases.randomElement()!
        engine.lfo2.destination1 = LFODestination.allCases.randomElement()!
        engine.lfo2.destination2 = LFODestination.allCases.randomElement()!
        engine.lfo2.amount1 = Float.random(in: 0...1)
        engine.lfo2.amount2 = Float.random(in: 0...1)
        engine.lfo2.rate = Float.random(in: 0.1...10)
    }
}
