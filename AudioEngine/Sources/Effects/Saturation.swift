import Foundation

/// Warm tape-style saturation.
public final class Saturation: ObservableObject {
    @Published public var dryWet: Float = 0
    @Published public var drive: Float = 0.5
    @Published public var warmth: Float = 0.5

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        let gain = 1.0 + drive * 5.0

        for i in 0..<sampleCount {
            let dry = buffer[i]
            var wet = tanh(dry * gain) / tanh(gain)
            // Warmth = subtle low-end boost via simple one-pole
            wet = wet * (1.0 + warmth * 0.2)
            buffer[i] = dry * (1 - dryWet) + wet * dryWet
        }
    }

    public func randomize() {
        drive = Float.random(in: 0.1...1.0)
        warmth = Float.random(in: 0...1)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
