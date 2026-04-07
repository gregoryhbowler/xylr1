import Foundation

/// Rhythmic volume gate (trance/sidechain style).
public final class Gate: ObservableObject {
    @Published public var dryWet: Float = 0
    @Published public var rate: Float = 4.0    // divisions
    @Published public var depth: Float = 1.0
    @Published public var shape: Float = 0.5   // attack shape
    private var phase: Float = 0

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        let increment = rate / 44100.0
        for i in 0..<sampleCount {
            phase += increment
            if phase >= 1.0 { phase -= 1.0 }
            let gate = phase < shape ? phase / shape : 1.0
            let mod = 1.0 - depth * (1.0 - gate)
            buffer[i] *= 1.0 - dryWet + dryWet * mod
        }
    }

    public func randomize() {
        rate = Float.random(in: 1...16)
        depth = Float.random(in: 0.5...1.0)
        shape = Float.random(in: 0.1...0.9)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
