import Foundation

/// Mutable Instruments Clouds-inspired granular processor.
///
/// Captures input into a circular buffer, then spawns overlapping grains
/// at configurable density with pitch shifting, random position scatter,
/// and Hann-windowed envelopes. Gain is normalized by active grain count.
///
/// Reference: pichenettes/eurorack/clouds
public final class GranularProcessor: ObservableObject {

    @Published public var dryWet: Float = 0
    @Published public var grainSize: Float = 0.1       // seconds (0.01 - 0.5)
    @Published public var density: Float = 0.5         // 0-1 (maps to overlap)
    @Published public var pitch: Float = 0             // semitones (-24 to +24)
    @Published public var position: Float = 0.5        // 0-1 read position in buffer
    @Published public var spray: Float = 0             // 0-1 position randomization
    @Published public var feedback: Float = 0          // 0-1
    @Published public var texture: Float = 0.5         // 0-1 window shape (rect → hann)
    @Published public var stereoSpread: Float = 0      // 0-1

    // Circular recording buffer (~4 seconds at 44.1kHz)
    private let bufferSize = 176400
    private var circularBuffer: [Float]
    private var writeHead: Int = 0
    private var frozen = false

    // Grain pool
    private let maxGrains = 40
    private var grains: [Grain] = []
    private var grainRatePhasor: Float = 0
    private var smoothedGrainCount: Float = 1

    // Feedback state
    private var feedbackBuffer: [Float]
    private var hpState: Float = 0  // High-pass on feedback to prevent DC

    private let sampleRate: Float = 44100

    public init() {
        circularBuffer = Array(repeating: 0, count: 176400)
        feedbackBuffer = Array(repeating: 0, count: 176400)
        grains = (0..<40).map { _ in Grain() }
    }

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }

        // Compute derived parameters
        let grainSizeSamples = max(64, Int(grainSize * sampleRate))
        let pitchRatio = powf(2.0, pitch / 12.0)
        let phaseIncrement = pitchRatio  // Playback speed multiplier

        // Density → overlap (Clouds-style meta-mapping)
        let overlap: Float
        let useDeterministic: Bool
        if density >= 0.53 {
            overlap = (density - 0.53) * 2.12
            useDeterministic = false
        } else if density <= 0.47 {
            overlap = (0.47 - density) * 2.12
            useDeterministic = true
        } else {
            overlap = 0
            useDeterministic = true
        }

        let targetGrains = max(1, Float(maxGrains) * overlap)
        let spaceBetweenGrains = Float(grainSizeSamples) / targetGrains

        for i in 0..<sampleCount {
            let dry = buffer[i]

            // Write input + feedback into circular buffer
            if !frozen {
                let fb = feedbackBuffer[writeHead] * feedback
                // High-pass the feedback to prevent DC buildup
                let hpInput = dry + fb
                let hpOutput = hpInput - hpState
                hpState += 0.001 * (hpInput - hpState)
                circularBuffer[writeHead] = softLimit(hpOutput)
                writeHead = (writeHead + 1) % bufferSize
            }

            // Grain seeding
            grainRatePhasor += 1.0
            var shouldSeed = false
            if useDeterministic {
                shouldSeed = grainRatePhasor >= spaceBetweenGrains
            } else {
                shouldSeed = Float.random(in: 0...1) < (targetGrains / Float(grainSizeSamples))
            }

            if shouldSeed, let freeGrain = grains.firstIndex(where: { !$0.active }) {
                seedGrain(&grains[freeGrain], grainSize: grainSizeSamples,
                         phaseIncrement: phaseIncrement)
                grainRatePhasor = 0
            }

            // Render active grains
            var wet: Float = 0
            var activeCount: Float = 0

            for g in grains.indices {
                guard grains[g].active else { continue }
                activeCount += 1

                // Compute envelope (triangular with Hann smoothing via texture)
                let envPhase = grains[g].envelopePhase
                var envelope: Float
                if envPhase < 1.0 {
                    envelope = envPhase
                } else {
                    envelope = 2.0 - envPhase
                }
                // Blend toward Hann window based on texture
                let hannEnv = 0.5 * (1.0 - cosf(envPhase * .pi))
                envelope = envelope * (1.0 - texture) + hannEnv * texture

                // Read from buffer with linear interpolation
                let readPos = grains[g].position
                let idx0 = Int(readPos) % bufferSize
                let idx1 = (idx0 + 1) % bufferSize
                let frac = readPos - Float(Int(readPos))
                let safeIdx0 = (idx0 + bufferSize) % bufferSize
                let safeIdx1 = (idx1 + bufferSize) % bufferSize
                let sample = circularBuffer[safeIdx0] * (1 - frac)
                           + circularBuffer[safeIdx1] * frac

                wet += sample * envelope

                // Advance grain
                grains[g].position += grains[g].phaseIncrement
                grains[g].envelopePhase += grains[g].envelopeIncrement
                if grains[g].envelopePhase >= 2.0 {
                    grains[g].active = false
                }
            }

            // Gain normalization (Clouds-style: 1/sqrt(numGrains))
            smoothedGrainCount += 0.01 * (max(1, activeCount) - smoothedGrainCount)
            let gainNorm = 1.0 / sqrtf(smoothedGrainCount)
            wet *= gainNorm

            // Store for feedback path
            let writeIdx = ((writeHead - 1) + bufferSize) % bufferSize
            feedbackBuffer[writeIdx] = wet

            buffer[i] = dry * (1 - dryWet) + wet * dryWet
        }
    }

    private func seedGrain(_ grain: inout Grain, grainSize: Int, phaseIncrement: Float) {
        // Position in buffer: based on position param + spray randomization
        let bufAvailable = Float(bufferSize - grainSize)
        let basePos = Float(writeHead) - position * bufAvailable
        let sprayOffset = spray * Float.random(in: -0.5...0.5) * Float(grainSize)
        var startPos = basePos + sprayOffset
        if startPos < 0 { startPos += Float(bufferSize) }

        grain.active = true
        grain.position = startPos
        grain.phaseIncrement = phaseIncrement
        grain.envelopePhase = 0
        grain.envelopeIncrement = 2.0 / Float(grainSize)
    }

    private func softLimit(_ x: Float) -> Float {
        if x > 1.0 { return 1.0 - 2.0 / (1.0 + 2.0 * x) }
        if x < -1.0 { return -1.0 + 2.0 / (1.0 - 2.0 * x) }
        return x
    }

    public func randomize() {
        grainSize = Float.random(in: 0.02...0.3)
        density = Float.random(in: 0.2...0.9)
        pitch = Float(Int.random(in: -12...12))
        position = Float.random(in: 0...1)
        spray = Float.random(in: 0...0.7)
        feedback = Float.random(in: 0...0.6)
        texture = Float.random(in: 0.2...1.0)
        dryWet = Float.random(in: 0.3...1.0)
    }
}

// MARK: - Grain

extension GranularProcessor {
    struct Grain {
        var active: Bool = false
        var position: Float = 0           // fractional sample position in buffer
        var phaseIncrement: Float = 1.0   // playback rate (pitch)
        var envelopePhase: Float = 0      // 0→2 triangle envelope
        var envelopeIncrement: Float = 0  // per-sample envelope advance
    }
}
