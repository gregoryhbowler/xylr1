import Foundation

/// Simple feedback delay network reverb.
public final class Reverb: ObservableObject {
    @Published public var dryWet: Float = 0
    @Published public var size: Float = 0.5
    @Published public var damping: Float = 0.5
    @Published public var preDelay: Float = 0.02

    // Simple 4-tap FDN
    private var delays: [[Float]] = [
        Array(repeating: 0, count: 1557),
        Array(repeating: 0, count: 1617),
        Array(repeating: 0, count: 1491),
        Array(repeating: 0, count: 1422),
    ]
    private var indices = [0, 0, 0, 0]
    private var dampState: [Float] = [0, 0, 0, 0]

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        let fb = size * 0.85

        for i in 0..<sampleCount {
            let dry = buffer[i]
            var wet: Float = 0

            for t in 0..<4 {
                let delayed = delays[t][indices[t]]
                dampState[t] = dampState[t] + (1 - damping) * (delayed - dampState[t])
                wet += dampState[t]
                delays[t][indices[t]] = dry + dampState[t] * fb
                indices[t] = (indices[t] + 1) % delays[t].count
            }
            wet *= 0.25

            buffer[i] = dry * (1 - dryWet) + wet * dryWet
        }
    }

    public func randomize() {
        size = Float.random(in: 0.1...0.95)
        damping = Float.random(in: 0.1...0.9)
        preDelay = Float.random(in: 0...0.1)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
