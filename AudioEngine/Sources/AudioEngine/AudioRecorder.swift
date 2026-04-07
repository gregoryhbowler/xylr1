import AVFoundation
import Combine

/// Records the final audio output to a WAV file.
public final class AudioRecorder: ObservableObject {

    @Published public private(set) var isRecording = false
    @Published public private(set) var recordingDuration: TimeInterval = 0

    private var audioFile: AVAudioFile?
    private var startTime: Date?

    public init() {}

    public func startRecording() {
        let url = Self.temporaryFileURL()
        let format = AVAudioFormat(
            standardFormatWithSampleRate: AudioEngine.sampleRate,
            channels: 2
        )!
        do {
            audioFile = try AVAudioFile(forWriting: url, settings: format.settings)
            startTime = Date()
            isRecording = true
        } catch {
            print("AudioRecorder: failed to start — \(error)")
        }
    }

    public func stopRecording() -> URL? {
        isRecording = false
        let url = audioFile?.url
        audioFile = nil
        startTime = nil
        recordingDuration = 0
        return url
    }

    public func writeBuffer(_ buffer: AVAudioPCMBuffer) {
        guard isRecording, let file = audioFile else { return }
        do {
            try file.write(from: buffer)
            if let start = startTime {
                recordingDuration = Date().timeIntervalSince(start)
            }
        } catch {
            print("AudioRecorder: write error — \(error)")
        }
    }

    private static func temporaryFileURL() -> URL {
        let dir = FileManager.default.temporaryDirectory
        return dir.appendingPathComponent("xylr1_recording_\(UUID().uuidString).wav")
    }
}
