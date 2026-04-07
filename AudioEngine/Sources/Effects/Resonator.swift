import Foundation

/// Modal/sympathetic resonance effect.
public final class Resonator: ObservableObject {
    @Published public var dryWet: Float = 0
    @Published public var frequency: Float = 440
    @Published public var decay: Float = 0.5
    @Published public var brightness: Float = 0.5
    @Published public var structure: Float = 0.5

    private var state: [Float] = Array(repeating: 0, count: 4)

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        let sampleRate: Float = 44100
        let w = 2.0 * Float.pi * frequency / sampleRate
        let r = decay * 0.999

        for i in 0..<sampleCount {
            let dry = buffer[i]
            let excitation = dry * (1 - r)
            state[0] = state[0] * r * cos(w) - state[1] * r * sin(w) + excitation
            state[1] = state[0] * r * sin(w) + state[1] * r * cos(w)
            let wet = state[0] * brightness
            buffer[i] = dry * (1 - dryWet) + wet * dryWet
        }
    }

    public func randomize() {
        frequency = Float.random(in: 60...2000)
        decay = Float.random(in: 0.1...0.99)
        brightness = Float.random(in: 0.1...1.0)
        structure = Float.random(in: 0...1)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
