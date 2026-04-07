import Foundation

/// A single note event in a group — can be a single note or chord.
public struct NoteEvent: Codable {
    public let midiNotes: [UInt8]
    public let velocity: UInt8
    public let timestamp: UInt64  // in master clock ticks

    public init(midiNotes: [UInt8], velocity: UInt8 = 100, timestamp: UInt64 = 0) {
        self.midiNotes = midiNotes
        self.velocity = velocity
        self.timestamp = timestamp
    }
}

/// A group stores an ordered list of note events for arp playback.
public final class Group: ObservableObject, Identifiable {
    public let id: Int
    @Published public var events: [NoteEvent] = []
    @Published public var isActive: Bool = false
    @Published public var isRecording: Bool = false

    public init(id: Int) {
        self.id = id
    }

    public func addEvent(_ event: NoteEvent) {
        events.append(event)
    }

    public func clear() {
        events.removeAll()
    }
}

/// Manages 8 groups per layer.
public final class GroupManager: ObservableObject {
    @Published public var groups: [Group]

    public static let groupCount = 8

    public init() {
        groups = (1...Self.groupCount).map { Group(id: $0) }
    }

    /// All notes from currently active groups, flattened.
    public var activeNotes: [UInt8] {
        groups
            .filter(\.isActive)
            .flatMap(\.events)
            .flatMap(\.midiNotes)
    }

    public func toggleGroup(_ index: Int) {
        guard index < groups.count else { return }
        groups[index].isActive.toggle()
    }

    public func toggleRecording(_ index: Int) {
        guard index < groups.count else { return }
        groups[index].isRecording.toggle()
    }
}
