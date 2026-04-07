import Foundation

/// Simple tilt EQ.
public final class EQ: ObservableObject {
    @Published public var dryWet: Float = 0
    @Published public var tilt: Float = 0        // -1 (dark) to +1 (bright)
    @Published public var frequency: Float = 1000 // pivot frequency
    @Published public var gain: Float = 0         // dB

    private var lpState: Float = 0

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        let coeff = exp(-2.0 * Float.pi * frequency / 44100.0)
        let lowGain = 1.0 - tilt * 0.5
        let highGain = 1.0 + tilt * 0.5

        for i in 0..<sampleCount {
            let dry = buffer[i]
            lpState = lpState + (1 - coeff) * (dry - lpState)
            let lp = lpState
            let hp = dry - lp
            let wet = lp * lowGain + hp * highGain
            buffer[i] = dry * (1 - dryWet) + wet * dryWet
        }
    }

    public func randomize() {
        tilt = Float.random(in: -1...1)
        frequency = Float.random(in: 200...5000)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
