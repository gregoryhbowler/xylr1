import Foundation

/// Manages polyphonic voice allocation with oldest-note-first stealing.
public final class VoiceAllocator {

    public struct VoiceState {
        public var isActive: Bool = false
        public var midiNote: UInt8 = 0
        public var velocity: UInt8 = 0
        public var startTime: UInt64 = 0
    }

    public private(set) var voices: [VoiceState]
    private var noteCounter: UInt64 = 0

    public init(voiceCount: Int) {
        voices = Array(repeating: VoiceState(), count: voiceCount)
    }

    /// Allocate a voice for the given note. Returns the voice index.
    @discardableResult
    public func noteOn(midiNote: UInt8, velocity: UInt8) -> Int {
        noteCounter += 1

        // Check if this note is already playing — retrigger it
        if let existing = voices.firstIndex(where: { $0.isActive && $0.midiNote == midiNote }) {
            voices[existing].velocity = velocity
            voices[existing].startTime = noteCounter
            return existing
        }

        // Find a free voice
        if let free = voices.firstIndex(where: { !$0.isActive }) {
            voices[free] = VoiceState(
                isActive: true, midiNote: midiNote,
                velocity: velocity, startTime: noteCounter
            )
            return free
        }

        // Steal the oldest voice
        let oldest = voices.enumerated().min(by: { $0.element.startTime < $1.element.startTime })!.offset
        voices[oldest] = VoiceState(
            isActive: true, midiNote: midiNote,
            velocity: velocity, startTime: noteCounter
        )
        return oldest
    }

    /// Release the voice playing the given note.
    public func noteOff(midiNote: UInt8) {
        if let idx = voices.firstIndex(where: { $0.isActive && $0.midiNote == midiNote }) {
            voices[idx].isActive = false
        }
    }

    /// Release all voices.
    public func allNotesOff() {
        for i in voices.indices {
            voices[i].isActive = false
        }
    }
}
