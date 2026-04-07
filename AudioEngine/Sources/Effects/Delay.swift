import Foundation

/// Mimeoclon-inspired delay engine. Per-layer, sits between synth output and Animation FX.
public final class DelayEngine: ObservableObject {

    public enum Range: Int, CaseIterable, Codable {
        case a = 0, b, c, d

        public var multiplier: Float {
            switch self {
            case .a: return 0.25
            case .b: return 0.5
            case .c: return 1.0
            case .d: return 2.0
            }
        }

        public var label: String {
            switch self {
            case .a: return "A"
            case .b: return "B"
            case .c: return "C"
            case .d: return "D"
            }
        }
    }

    @Published public var range: Range = .c
    @Published public var rate: Int = 12            // 1-24 subdivisions
    @Published public var modAmount: Float = 0      // 0-1
    @Published public var modFrequency: Float = 0   // 0-1
    @Published public var stereo: Float = 0.5       // 0=L, 0.5=center, 1=R
    @Published public var repeats: Float = 0.4      // 0-1.2 (>1 = self-oscillation)
    @Published public var tone: Float = 0.5         // 0-1 (dark to bright)
    @Published public var glow: Float = 0           // 0-1 (diffusion/shimmer)
    @Published public var mix: Float = 0            // dry/wet 0-1

    // Delay buffer (~2 seconds stereo at 44.1kHz)
    private var bufferL: [Float] = Array(repeating: 0, count: 88200)
    private var bufferR: [Float] = Array(repeating: 0, count: 88200)
    private var writeIndex = 0
    private var modPhase: Float = 0
    private var toneFilterState: Float = 0

    public init() {}

    /// Calculate delay time in samples based on BPM, rate, and range.
    public func delayTimeSamples(bpm: Double) -> Int {
        let beatsPerSecond = bpm / 60.0
        let divisionSeconds = 1.0 / (beatsPerSecond * Double(rate))
        let samples = divisionSeconds * 44100 * Double(range.multiplier)
        return max(1, Int(samples))
    }

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int, bpm: Double = 120) {
        guard mix > 0 else { return }
        let delaySamples = delayTimeSamples(bpm: bpm)
        let modIncrement = modFrequency * 5.0 / 44100.0
        let toneCoeff = tone

        for i in 0..<sampleCount {
            // Modulation
            modPhase += modIncrement
            if modPhase >= 1.0 { modPhase -= 1.0 }
            let mod = sin(modPhase * .pi * 2) * modAmount * 100

            let readOffset = Float(delaySamples) + mod
            let readIdx = (writeIndex - Int(readOffset) + bufferL.count) % bufferL.count

            // Read delayed signal
            var delayed = bufferL[readIdx]

            // Tone filter on feedback
            toneFilterState = toneFilterState + toneCoeff * (delayed - toneFilterState)
            delayed = toneFilterState

            // Write to buffer with feedback
            let dry = buffer[i]
            bufferL[writeIndex] = dry + delayed * repeats

            // Output mix
            buffer[i] = dry * (1 - mix) + delayed * mix

            writeIndex = (writeIndex + 1) % bufferL.count
        }
    }

    public func randomize() {
        range = Range.allCases.randomElement()!
        rate = Int.random(in: 1...24)
        modAmount = Float.random(in: 0...0.5)
        modFrequency = Float.random(in: 0...0.5)
        stereo = Float.random(in: 0...1)
        repeats = Float.random(in: 0.1...0.8)
        tone = Float.random(in: 0.2...0.8)
        glow = Float.random(in: 0...0.5)
        mix = Float.random(in: 0.2...0.7)
    }
}
