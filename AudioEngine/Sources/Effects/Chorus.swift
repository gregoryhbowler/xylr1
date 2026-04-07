import Foundation

/// Modulated delay chorus effect.
public final class Chorus: ObservableObject {

    @Published public var dryWet: Float = 0
    @Published public var rate: Float = 1.0
    @Published public var depth: Float = 0.5
    @Published public var voices: Int = 3

    private var delayBuffer: [Float] = Array(repeating: 0, count: 8192)
    private var writeIndex: Int = 0
    private var phase: Float = 0

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        let sampleRate: Float = 44100
        let lfoIncrement = rate / sampleRate

        for i in 0..<sampleCount {
            phase += lfoIncrement
            if phase >= 1.0 { phase -= 1.0 }

            delayBuffer[writeIndex] = buffer[i]

            var wet: Float = 0
            for v in 0..<voices {
                let vPhase = phase + Float(v) / Float(voices)
                let lfo = sin(vPhase * .pi * 2)
                let delaySamples = (lfo * depth * 0.02 * sampleRate) + 0.01 * sampleRate
                wet += readDelay(delaySamples)
            }
            wet /= Float(voices)

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
        rate = Float.random(in: 0.1...3.0)
        depth = Float.random(in: 0.1...1.0)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
