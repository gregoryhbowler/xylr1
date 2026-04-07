import Foundation

/// Transport state for loop recorder on the main view.
struct TransportState {
    enum Mode {
        case idle, recording, playing, paused
    }

    var mode: Mode = .idle
    var loopLength: TimeInterval = 0

    var isRecording: Bool { mode == .recording }
    var isPlaying: Bool { mode == .playing }
}
