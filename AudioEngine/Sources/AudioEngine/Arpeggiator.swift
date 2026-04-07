import Foundation

/// Arp path mode — determines note traversal order.
public enum ArpPath: Int, CaseIterable, Codable {
    case off = 0          // User entry order
    case forward = 1      // 1-2-3-4, 5-6-7-8
    case pendulum = 2     // forward then reverse
    case interleave = 3   // 1-5-2-6, 3-7-4-8
    case zigzag = 4       // 1-3-2-4, 5-7-6-8
    case scatter = 5      // 1-5-2-7, 4-8-3-6
    case additive = 6     // 1, 1-2, 1-3, ... 1-8
    case randomLoop = 7   // random N-note loop
    case randomAll = 8    // random, all notes, no repeats
}

/// Arpeggiator engine for a single layer.
public final class Arpeggiator: ObservableObject {

    @Published public var path: ArpPath = .off
    @Published public var rate: Double = 0.25        // quarter note default
    @Published public var swing: Float = 0           // 0-100%
    @Published public var ratchet: Int = 0           // 0-16
    @Published public var randomOctave: Float = 0    // 0-100%
    @Published public var randomNote: Float = 0      // 0-100%
    @Published public var playbackRate: Double = 1.0  // 1/4 to 8/8
    @Published public var quantizeMidi: Double = 0.25 // grid value
    @Published public var randomLoopLength: Int = 5   // for path 7

    private var activeNotes: [UInt8] = []
    private var stepIndex: Int = 0
    private var pendulumForward = true

    public init() {}

    /// Set the active note pool (sorted low to high for path modes).
    public func setNotes(_ notes: [UInt8]) {
        activeNotes = notes.sorted()
        stepIndex = 0
        pendulumForward = true
    }

    /// Get the next note(s) to play based on current path mode.
    public func nextStep() -> [UInt8] {
        guard !activeNotes.isEmpty else { return [] }

        switch path {
        case .off:
            return advanceLinear()
        case .forward:
            return advanceLinear()
        case .pendulum:
            return advancePendulum()
        case .interleave:
            return advancePattern([0, 4, 1, 5, 2, 6, 3, 7])
        case .zigzag:
            return advancePattern([0, 2, 1, 3, 4, 6, 5, 7])
        case .scatter:
            return advancePattern([0, 4, 1, 6, 3, 7, 2, 5])
        case .additive:
            return advanceAdditive()
        case .randomLoop:
            return advanceRandomLoop()
        case .randomAll:
            return advanceRandomAll()
        }
    }

    // MARK: - Path Algorithms

    private func advanceLinear() -> [UInt8] {
        let note = activeNotes[stepIndex % activeNotes.count]
        stepIndex += 1
        return [note]
    }

    private func advancePendulum() -> [UInt8] {
        let note = activeNotes[stepIndex % activeNotes.count]
        if pendulumForward {
            stepIndex += 1
            if stepIndex >= activeNotes.count {
                stepIndex = activeNotes.count - 1
                pendulumForward = false
            }
        } else {
            stepIndex -= 1
            if stepIndex < 0 {
                stepIndex = 0
                pendulumForward = true
            }
        }
        return [note]
    }

    private func advancePattern(_ order: [Int]) -> [UInt8] {
        let validOrder = order.filter { $0 < activeNotes.count }
        guard !validOrder.isEmpty else { return advanceLinear() }
        let idx = validOrder[stepIndex % validOrder.count]
        stepIndex += 1
        return [activeNotes[idx]]
    }

    private func advanceAdditive() -> [UInt8] {
        let count = (stepIndex % activeNotes.count) + 1
        stepIndex += 1
        return [activeNotes[count - 1]]
    }

    private func advanceRandomLoop() -> [UInt8] {
        let idx = Int.random(in: 0..<activeNotes.count)
        return [activeNotes[idx]]
    }

    private func advanceRandomAll() -> [UInt8] {
        return [activeNotes.randomElement()].compactMap { $0 }
    }
}
