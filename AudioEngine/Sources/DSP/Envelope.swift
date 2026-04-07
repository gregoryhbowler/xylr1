import Foundation

/// ADSR envelope generator.
public final class Envelope {

    public enum Stage {
        case idle, attack, decay, sustain, release
    }

    public var attackTime: Float = 0.01   // seconds
    public var decayTime: Float = 0.1     // seconds
    public var sustainLevel: Float = 0.8  // 0-1
    public var releaseTime: Float = 0.3   // seconds

    public private(set) var stage: Stage = .idle
    public private(set) var output: Float = 0

    public var isIdle: Bool { stage == .idle }

    private var sampleRate: Float = 44100
    private var attackRate: Float = 0
    private var decayRate: Float = 0
    private var releaseRate: Float = 0

    public init(sampleRate: Float = 44100) {
        self.sampleRate = sampleRate
        recalculate()
    }

    public func recalculate() {
        attackRate = attackTime > 0 ? 1.0 / (attackTime * sampleRate) : 1.0
        decayRate = decayTime > 0 ? 1.0 / (decayTime * sampleRate) : 1.0
        releaseRate = releaseTime > 0 ? 1.0 / (releaseTime * sampleRate) : 1.0
    }

    public func gate(on: Bool) {
        if on {
            stage = .attack
            recalculate()
        } else if stage != .idle {
            stage = .release
            recalculate()
        }
    }

    /// Process one sample. Returns the envelope value (0-1).
    public func process() -> Float {
        switch stage {
        case .idle:
            return 0
        case .attack:
            output += attackRate
            if output >= 1.0 {
                output = 1.0
                stage = .decay
            }
        case .decay:
            output -= decayRate * (1.0 - sustainLevel)
            if output <= sustainLevel {
                output = sustainLevel
                stage = .sustain
            }
        case .sustain:
            output = sustainLevel
        case .release:
            output -= releaseRate * output
            if output <= 0.001 {
                output = 0
                stage = .idle
            }
        }
        return output
    }
}
