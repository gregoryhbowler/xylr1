import Foundation

/// Modulated delay-line flanger effect.
public final class Flanger: ObservableObject {

    @Published public var dryWet: Float = 0
    @Published public var rate: Float = 0.3
    @Published public var depth: Float = 0.5
    @Published public var feedback: Float = 0.5

    private var delayBuffer: [Float] = Array(repeating: 0, count: 4096)
    private var writeIndex: Int = 0
    private var phase: Float = 0

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        let sampleRate: Float = 44100
        let maxDelay: Float = 0.005 * sampleRate // 5ms max
        let lfoIncrement = rate / sampleRate

        for i in 0..<sampleCount {
            phase += lfoIncrement
            if phase >= 1.0 { phase -= 1.0 }

            let lfo = (sin(phase * .pi * 2) + 1) * 0.5
            let delaySamples = lfo * depth * maxDelay + 1

            delayBuffer[writeIndex] = buffer[i] + feedback * readDelay(delaySamples)
            let wet = readDelay(delaySamples)
            buffer[i] = buffer[i] * (1 - dryWet) + wet * dryWet

            writeIndex = (writeIndex + 1) % delayBuffer.count
        }
    }

    private func readDelay(_ samples: Float) -> Float {
        let readPos = Float(writeIndex) - samples
        let idx = Int(readPos) % delayBuffer.count
        let safeIdx = idx < 0 ? idx + delayBuffer.count : idx
        return delayBuffer[safeIdx]
    }

    public func randomize() {
        rate = Float.random(in: 0.05...2.0)
        depth = Float.random(in: 0.1...1.0)
        feedback = Float.random(in: 0...0.9)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
