import SwiftUI
import Combine
import AudioEngine

/// Centralized application state — single source of truth for all UI.
@MainActor
final class AppState: ObservableObject {

    // MARK: - Layers

    @Published var layers: [LayerState] = [LayerState(index: 0)]
    @Published var activeLayerIndex: Int = 0

    var activeLayer: LayerState {
        get { layers[activeLayerIndex] }
        set { layers[activeLayerIndex] = newValue }
    }

    // MARK: - Master

    @Published var masterBPM: Double = 120.0
    @Published var masterTransport = TransportState()
    @Published var revise = ReviseState()

    // MARK: - Navigation

    @Published var currentView: AppView = .layer

    enum AppView {
        case layer
        case synth
        case animation
        case delay
        case environment
        case treatment
        case revise
    }

    // MARK: - Audio Engine

    let audioEngine = AudioEngine()

    // MARK: - Preset Manager

    let presetManager = PresetManager()

    // MARK: - Init

    init() {
        audioEngine.start()
        // Sync initial BPM
        audioEngine.masterClock.bpm = masterBPM
    }

    // MARK: - Layer Management

    func addLayer() {
        guard layers.count < 4 else { return }
        let newLayer = LayerState(index: layers.count)
        layers.append(newLayer)
        // Add a corresponding engine layer with polyrhythmic suggestion
        let suggestedRatios: [TempoRatio] = [
            TempoRatio(numerator: 3, denominator: 4),
            TempoRatio(numerator: 2, denominator: 3),
            TempoRatio(numerator: 5, denominator: 4),
        ]
        let ratio = suggestedRatios[min(layers.count - 2, suggestedRatios.count - 1)]
        audioEngine.addLayer(tempoRatio: ratio)
    }

    func removeLayer(at index: Int) {
        guard layers.count > 1, index < layers.count else { return }
        layers.remove(at: index)
        if activeLayerIndex >= layers.count {
            activeLayerIndex = layers.count - 1
        }
    }

    // MARK: - Note Playback

    func noteOn(_ midiNote: UInt8) {
        syncSynthParams()
        audioEngine.noteOn(layer: activeLayerIndex, midiNote: midiNote)
    }

    func noteOff(_ midiNote: UInt8) {
        audioEngine.noteOff(layer: activeLayerIndex, midiNote: midiNote)
    }

    // MARK: - Param Sync

    /// Push current UI synth params to the audio engine layer.
    func syncSynthParams() {
        guard activeLayerIndex < audioEngine.layers.count else { return }
        let layer = activeLayer
        let engine = audioEngine.layers[activeLayerIndex]
        engine.model = layer.model
        engine.harmonics = layer.harmonics
        engine.timbre = layer.timbre
        engine.morph = layer.morph
        engine.cutoff = layer.cutoff
        engine.resonance = layer.resonance
        engine.attackTime = layer.attackTime
        engine.decayTime = layer.decayTime
        engine.sustainLevel = layer.sustainLevel
        engine.releaseTime = layer.releaseTime
        engine.monoMode = layer.monoMode
    }

    func syncBPM() {
        audioEngine.masterClock.bpm = masterBPM
    }

    // MARK: - Audio Recording

    @Published var isRecordingOutput: Bool = false

    // MARK: - Undo

    func saveUndoSnapshot() {
        layers[activeLayerIndex].undoSnapshot = layers[activeLayerIndex]
    }

    func undo() {
        if let snapshot = layers[activeLayerIndex].undoSnapshot {
            let currentIndex = layers[activeLayerIndex].index
            layers[activeLayerIndex] = snapshot
            // Preserve identity
            layers[activeLayerIndex].undoSnapshot = nil
        }
    }
}
