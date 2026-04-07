import Foundation

/// LFO waveform shape.
public enum LFOShape: Int, CaseIterable, Codable, CustomStringConvertible {
    case sine, triangle, sawUp, sawDown, square, sampleAndHold, randomWalk

    public var description: String {
        switch self {
        case .sine: return "SINE"
        case .triangle: return "TRI"
        case .sawUp: return "SAW↑"
        case .sawDown: return "SAW↓"
        case .square: return "SQR"
        case .sampleAndHold: return "S&H"
        case .randomWalk: return "RND"
        }
    }
}

/// LFO modulation destination.
public enum LFODestination: Int, CaseIterable, Codable, CustomStringConvertible {
    case none, model, harmonics, timbre, morph, cutoff, resonance
    case ampAttack, ampDecay, ampSustain, ampRelease, volume

    public var description: String {
        switch self {
        case .none: return "NONE"
        case .model: return "MODEL"
        case .harmonics: return "HARM"
        case .timbre: return "TIMBRE"
        case .morph: return "MORPH"
        case .cutoff: return "CUTOFF"
        case .resonance: return "RESO"
        case .ampAttack: return "ATT"
        case .ampDecay: return "DEC"
        case .ampSustain: return "SUS"
        case .ampRelease: return "REL"
        case .volume: return "VOL"
        }
    }
}

/// Low-frequency oscillator with dual destinations and sync.
public final class LFO: ObservableObject {

    @Published public var shape: LFOShape = .sine
    @Published public var destination1: LFODestination = .none
    @Published public var destination2: LFODestination = .none
    @Published public var amount1: Float = 0   // 0-1
    @Published public var amount2: Float = 0   // 0-1
    @Published public var rate: Float = 1.0    // Hz (free) or division (sync)
    @Published public var synced: Bool = false

    private var phase: Double = 0

    public init() {}

    /// Compute the current LFO value in -1...1 range.
    public func value(at phase: Double) -> Float {
        let p = phase.truncatingRemainder(dividingBy: 1.0)
        switch shape {
        case .sine:
            return Float(sin(p * .pi * 2))
        case .triangle:
            return p < 0.5 ? Float(p * 4 - 1) : Float(3 - p * 4)
        case .sawUp:
            return Float(p * 2 - 1)
        case .sawDown:
            return Float(1 - p * 2)
        case .square:
            return p < 0.5 ? 1 : -1
        case .sampleAndHold:
            return Float.random(in: -1...1)
        case .randomWalk:
            return Float.random(in: -1...1)
        }
    }

    /// Advance phase by the given number of samples. Returns current output.
    @discardableResult
    public func process(sampleCount: Int, sampleRate: Double) -> Float {
        let increment = Double(rate) / sampleRate * Double(sampleCount)
        phase += increment
        return value(at: phase)
    }
}
