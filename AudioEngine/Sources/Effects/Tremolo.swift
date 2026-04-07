import Foundation

/// Amplitude-modulation tremolo effect.
public final class Tremolo: ObservableObject {

    @Published public var dryWet: Float = 0
    @Published public var rate: Float = 4.0   // Hz
    @Published public var depth: Float = 0.5

    private var phase: Float = 0

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        let sampleRate: Float = 44100
        let increment = rate / sampleRate

        for i in 0..<sampleCount {
            phase += increment
            if phase >= 1.0 { phase -= 1.0 }

            let mod = 1.0 - depth * (sin(phase * .pi * 2) + 1) * 0.5
            let wet = buffer[i] * mod
            buffer[i] = buffer[i] * (1 - dryWet) + wet * dryWet
        }
    }

    public func randomize() {
        rate = Float.random(in: 0.5...20.0)
        depth = Float.random(in: 0.1...1.0)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
