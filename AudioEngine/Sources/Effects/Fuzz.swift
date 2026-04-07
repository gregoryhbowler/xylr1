import Foundation

/// Fuzz distortion effect.
public final class Fuzz: ObservableObject {
    @Published public var dryWet: Float = 0
    @Published public var drive: Float = 0.5
    @Published public var tone: Float = 0.5
    @Published public var gateThreshold: Float = 0

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        let gain = 1.0 + drive * 20.0

        for i in 0..<sampleCount {
            let dry = buffer[i]
            var wet = dry * gain
            // Asymmetric clipping for fuzz character
            if wet > 0 {
                wet = 1.0 - expf(-wet)
            } else {
                wet = -1.0 + expf(wet)
            }
            // Simple tone filter
            wet = wet * tone + wet * (1 - tone) * 0.5
            // Gate
            if abs(wet) < gateThreshold { wet = 0 }
            buffer[i] = dry * (1 - dryWet) + wet * dryWet
        }
    }

    public func randomize() {
        drive = Float.random(in: 0.1...1.0)
        tone = Float.random(in: 0...1)
        gateThreshold = Float.random(in: 0...0.1)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
