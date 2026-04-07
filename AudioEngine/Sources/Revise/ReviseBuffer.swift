import AVFoundation
import Foundation

/// Disk-backed audio buffer for the Revise sampler system.
/// Uses AVAudioFile for streaming — no length limit.
public final class ReviseBuffer: ObservableObject {

    public enum PlaybackMode: String, CaseIterable {
        case loop = "LOOP"
        case oneShot = "1-SHOT"
    }

    public enum State {
        case empty, recording, overdubbing, playing, paused
    }

    @Published public private(set) var state: State = .empty
    @Published public var playbackMode: PlaybackMode = .loop
    @Published public private(set) var duration: TimeInterval = 0
    @Published public private(set) var playbackPosition: TimeInterval = 0

    // Granular/playback parameters
    @Published public var pitch: Float = 0        // semitones
    @Published public var grainSize: Float = 0.05  // seconds
    @Published public var density: Float = 0.5
    @Published public var position: Float = 0      // 0-1 scrub
    @Published public var spread: Float = 0
    @Published public var hpf: Float = 20          // Hz
    @Published public var lpf: Float = 20000       // Hz
    @Published public var shape: Float = 0.5       // grain window
    @Published public var gain: Float = 1.0
    @Published public var delaySend: Float = 0
    @Published public var delayTime: Float = 0.3
    @Published public var delayFeedback: Float = 0.3
    @Published public var verbSend: Float = 0
    @Published public var verbSize: Float = 0.5

    private var audioFile: AVAudioFile?
    private var fileURL: URL?

    public init() {}

    // MARK: - Recording

    public func startRecording() {
        let url = Self.temporaryURL()
        let format = AVAudioFormat(
            standardFormatWithSampleRate: 44100,
            channels: 2
        )!
        do {
            audioFile = try AVAudioFile(forWriting: url, settings: format.settings)
            fileURL = url
            state = .recording
        } catch {
            print("ReviseBuffer: record start failed — \(error)")
        }
    }

    public func startOverdub() {
        guard state == .paused || state == .playing else { return }
        state = .overdubbing
    }

    public func stopRecording() {
        if state == .recording || state == .overdubbing {
            state = fileURL != nil ? .paused : .empty
            if let file = audioFile {
                duration = Double(file.length) / file.fileFormat.sampleRate
            }
        }
    }

    public func play() {
        guard fileURL != nil else { return }
        state = .playing
    }

    public func pause() {
        state = .paused
    }

    public func clear() {
        state = .empty
        audioFile = nil
        if let url = fileURL {
            try? FileManager.default.removeItem(at: url)
        }
        fileURL = nil
        duration = 0
        playbackPosition = 0
    }

    private static func temporaryURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("xylr1_revise_\(UUID().uuidString).wav")
    }
}
