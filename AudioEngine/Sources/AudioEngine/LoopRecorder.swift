import Foundation

/// Records and plays back MIDI performance sequences (note events timestamped in clock ticks).
public final class LoopRecorder: ObservableObject {

    public enum State {
        case idle, recording, playing, paused
    }

    public struct RecordedEvent: Codable {
        public let tick: UInt64
        public let midiNote: UInt8
        public let velocity: UInt8
        public let isNoteOn: Bool
    }

    @Published public private(set) var state: State = .idle
    @Published public private(set) var events: [RecordedEvent] = []

    private var recordStartTick: UInt64 = 0
    private var loopLengthTicks: UInt64 = 0
    private var playbackIndex: Int = 0

    public init() {}

    public func startRecording(atTick tick: UInt64) {
        events.removeAll()
        recordStartTick = tick
        state = .recording
    }

    public func stopRecording(atTick tick: UInt64) {
        loopLengthTicks = tick - recordStartTick
        // Snap to nearest bar (96 PPQN * 4 beats = 384 ticks per bar in 4/4)
        let ticksPerBar: UInt64 = 384
        if loopLengthTicks > 0 {
            loopLengthTicks = ((loopLengthTicks + ticksPerBar / 2) / ticksPerBar) * ticksPerBar
        }
        state = .idle
    }

    public func recordEvent(midiNote: UInt8, velocity: UInt8, isNoteOn: Bool, atTick tick: UInt64) {
        guard state == .recording else { return }
        let relativeTick = tick - recordStartTick
        events.append(RecordedEvent(
            tick: relativeTick,
            midiNote: midiNote,
            velocity: velocity,
            isNoteOn: isNoteOn
        ))
    }

    public func play() {
        guard !events.isEmpty else { return }
        playbackIndex = 0
        state = .playing
    }

    public func pause() {
        state = .paused
    }

    public func stop() {
        state = .idle
        playbackIndex = 0
    }
}
