import SwiftUI
import Combine

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

    // Will hold reference to AudioEngine when running
    // var audioEngine: AudioEngine?

    // MARK: - Layer Management

    func addLayer() {
        guard layers.count < 4 else { return }
        let newLayer = LayerState(index: layers.count)
        layers.append(newLayer)
    }

    func removeLayer(at index: Int) {
        guard layers.count > 1, index < layers.count else { return }
        layers.remove(at: index)
        if activeLayerIndex >= layers.count {
            activeLayerIndex = layers.count - 1
        }
    }

    // MARK: - Audio Recording

    @Published var isRecordingOutput: Bool = false
}
