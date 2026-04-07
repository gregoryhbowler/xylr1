import Foundation

/// Frequency shifter effect (up/down/through-zero).
public final class FrequencyShifter: ObservableObject {
    @Published public var dryWet: Float = 0
    @Published public var shiftAmount: Float = 0   // Hz
    @Published public var feedback: Float = 0
    @Published public var mode: Int = 0  // 0=up, 1=down, 2=through-zero

    private var phase: Float = 0

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        let sampleRate: Float = 44100
        let increment = shiftAmount / sampleRate

        for i in 0..<sampleCount {
            phase += increment
            if phase >= 1.0 { phase -= 1.0 }
            if phase < 0.0 { phase += 1.0 }

            let dry = buffer[i]
            let shifted = dry * cos(phase * .pi * 2)
            buffer[i] = dry * (1 - dryWet) + shifted * dryWet
        }
    }

    public func randomize() {
        shiftAmount = Float.random(in: -500...500)
        feedback = Float.random(in: 0...0.8)
        mode = Int.random(in: 0...2)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
