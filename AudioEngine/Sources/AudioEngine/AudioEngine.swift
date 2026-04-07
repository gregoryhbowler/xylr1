import AVFoundation
import Combine

/// Top-level audio engine coordinator.
/// Manages the audio graph, master clock, layers, treatment chain, and revise buffers.
public final class AudioEngine: ObservableObject {

    // MARK: - Published state for UI metering

    @Published public private(set) var isRunning = false
    @Published public private(set) var outputLevel: Float = 0

    // MARK: - Core components

    public let masterClock = MasterClock()
    public private(set) var layers: [LayerEngine] = []
    public let treatmentChain = TreatmentChain()
    public let reviseBuffers: [ReviseBuffer] = [ReviseBuffer(), ReviseBuffer()]
    public let audioRecorder = AudioRecorder()

    private let engine = AVAudioEngine()
    private let mixerNode = AVAudioMixerNode()

    // MARK: - Constants

    public static let sampleRate: Double = 44100
    public static let preferredBufferSize: UInt32 = 128
    public static let maxLayers = 4
    public static let voicesPerLayer = 8

    // MARK: - Init

    public init() {
        setupAudioSession()
        setupGraph()
        addLayer() // Start with Layer 1
    }

    // MARK: - Audio Session

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, options: .mixWithOthers)
            try session.setPreferredSampleRate(Self.sampleRate)
            try session.setPreferredIOBufferDuration(
                Double(Self.preferredBufferSize) / Self.sampleRate
            )
            try session.setActive(true)
        } catch {
            print("AudioEngine: failed to configure audio session — \(error)")
        }
    }

    // MARK: - Graph Setup

    private func setupGraph() {
        engine.attach(mixerNode)
        engine.connect(mixerNode, to: engine.mainMixerNode, format: nil)
    }

    // MARK: - Layer Management

    @discardableResult
    public func addLayer(tempoRatio: TempoRatio = .unison) -> LayerEngine? {
        guard layers.count < Self.maxLayers else { return nil }
        let layer = LayerEngine(
            index: layers.count,
            masterClock: masterClock,
            tempoRatio: tempoRatio
        )
        layers.append(layer)
        // In a full implementation, attach layer's audio node to the mixer
        return layer
    }

    // MARK: - Start / Stop

    public func start() {
        guard !isRunning else { return }
        do {
            try engine.start()
            masterClock.start()
            isRunning = true
        } catch {
            print("AudioEngine: failed to start — \(error)")
        }
    }

    public func stop() {
        engine.stop()
        masterClock.stop()
        isRunning = false
    }

    // MARK: - Note Input

    /// Trigger a note on a specific layer.
    public func noteOn(layer: Int, midiNote: UInt8, velocity: UInt8 = 100) {
        guard layer < layers.count else { return }
        layers[layer].noteOn(midiNote: midiNote, velocity: velocity)
    }

    /// Release a note on a specific layer.
    public func noteOff(layer: Int, midiNote: UInt8) {
        guard layer < layers.count else { return }
        layers[layer].noteOff(midiNote: midiNote)
    }
}
