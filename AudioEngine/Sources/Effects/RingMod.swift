import Foundation

/// Ring modulation effect.
public final class RingMod: ObservableObject {
    @Published public var dryWet: Float = 0
    @Published public var frequency: Float = 440
    @Published public var depth: Float = 1.0

    private var phase: Float = 0

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        let increment = frequency / 44100.0
        for i in 0..<sampleCount {
            phase += increment
            if phase >= 1.0 { phase -= 1.0 }
            let carrier = sin(phase * .pi * 2)
            let dry = buffer[i]
            let wet = dry * carrier * depth
            buffer[i] = dry * (1 - dryWet) + wet * dryWet
        }
    }

    public func randomize() {
        frequency = Float.random(in: 20...2000)
        depth = Float.random(in: 0.3...1.0)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
