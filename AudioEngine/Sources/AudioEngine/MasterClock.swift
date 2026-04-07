import Foundation
import Combine

/// Tempo ratio for polyrhythmic layer sync.
public struct TempoRatio: Equatable, Codable {
    public let numerator: Int
    public let denominator: Int

    public static let unison = TempoRatio(numerator: 1, denominator: 1)

    public var floatValue: Double {
        Double(numerator) / Double(denominator)
    }

    public init(numerator: Int, denominator: Int) {
        self.numerator = numerator
        self.denominator = denominator
    }

    /// Derive effective BPM from master BPM.
    public func effectiveBPM(masterBPM: Double) -> Double {
        masterBPM * floatValue
    }
}

/// 96 PPQN master clock driven by the audio render callback.
/// All timing in the app derives from this clock.
public final class MasterClock: ObservableObject {

    public static let ppqn: UInt32 = 96

    @Published public var bpm: Double = 120.0 {
        didSet { recalculatePulseDuration() }
    }

    @Published public private(set) var tickCount: UInt64 = 0
    @Published public private(set) var isRunning = false

    /// Samples per pulse at the current BPM and sample rate.
    public private(set) var samplesPerPulse: Double = 0

    /// Current beat position (fractional).
    public var beatPosition: Double {
        Double(tickCount) / Double(Self.ppqn)
    }

    /// Current bar position (assuming 4/4).
    public var barPosition: Double {
        beatPosition / 4.0
    }

    private var sampleRate: Double = 44100
    private var sampleAccumulator: Double = 0

    public init(sampleRate: Double = 44100) {
        self.sampleRate = sampleRate
        recalculatePulseDuration()
    }

    private func recalculatePulseDuration() {
        // seconds per beat = 60 / BPM
        // seconds per pulse = (60 / BPM) / PPQN
        // samples per pulse = sampleRate * secondsPerPulse
        let secondsPerPulse = 60.0 / (bpm * Double(Self.ppqn))
        samplesPerPulse = sampleRate * secondsPerPulse
    }

    /// Call from the audio render callback. Returns the number of pulses
    /// that occurred during this buffer.
    @discardableResult
    public func advance(sampleCount: Int) -> Int {
        guard isRunning else { return 0 }
        var pulses = 0
        sampleAccumulator += Double(sampleCount)
        while sampleAccumulator >= samplesPerPulse {
            sampleAccumulator -= samplesPerPulse
            tickCount += 1
            pulses += 1
        }
        return pulses
    }

    public func start() {
        isRunning = true
    }

    public func stop() {
        isRunning = false
    }

    public func reset() {
        tickCount = 0
        sampleAccumulator = 0
    }

    /// Tick count for a given layer ratio.
    public func layerTickCount(ratio: TempoRatio) -> UInt64 {
        UInt64(Double(tickCount) * ratio.floatValue)
    }
}
