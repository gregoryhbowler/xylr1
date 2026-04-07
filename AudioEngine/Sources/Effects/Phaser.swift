import Foundation

/// All-pass chain phaser effect.
public final class Phaser: ObservableObject {

    @Published public var dryWet: Float = 0   // 0-1
    @Published public var rate: Float = 0.5
    @Published public var depth: Float = 0.5
    @Published public var feedback: Float = 0.3
    @Published public var stages: Int = 4

    private var phase: Float = 0
    private var allPassOutputs: [Float] = Array(repeating: 0, count: 6)

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        let sampleRate: Float = 44100
        let lfoIncrement = rate / sampleRate

        for i in 0..<sampleCount {
            phase += lfoIncrement
            if phase >= 1.0 { phase -= 1.0 }

            let lfo = sin(phase * .pi * 2) * depth
            let dry = buffer[i]

            var wet = dry + feedback * allPassOutputs[0]
            for s in 0..<min(stages, 6) {
                let coeff = 0.5 + lfo * 0.4
                let output = wet * coeff + allPassOutputs[s]
                allPassOutputs[s] = wet - output * coeff
                wet = output
            }

            buffer[i] = dry * (1 - dryWet) + wet * dryWet
        }
    }

    public func randomize() {
        rate = Float.random(in: 0.1...5.0)
        depth = Float.random(in: 0.1...1.0)
        feedback = Float.random(in: 0...0.9)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
