import Foundation

/// Eventide H910-style pitch-shifting harmonizer.
///
/// Uses dual delay-line crossfade technique: two delay taps read at time-varying
/// rates, with sinusoidal crossfading to splice cleanly. The modulation frequency
/// is derived from the pitch ratio and delay buffer size.
///
/// Reference: Daisy-Patch-H910, DaisySP PitchShifter
public final class Harmonizer: ObservableObject {
    @Published public var dryWet: Float = 0
    @Published public var interval: Float = 0    // semitones (-12 to +12)
    @Published public var detune: Float = 0      // cents (-50 to +50)
    @Published public var mix: Float = 0.5       // wet signal level

    // Internal state
    private let sampleRate: Float = 44100
    private let delaySize: Int = 16384
    private var delayBuffer: [Float]
    private var writeIndex: Int = 0

    // Dual phasors for crossfade
    private var phasor0: Float = 0
    private var phasor1: Float = 0.5   // 180° offset

    // Smoothed parameters
    private var smoothedRatio: Float = 1.0

    public init() {
        delayBuffer = Array(repeating: 0, count: 16384)
    }

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }

        // Convert interval (semitones) + detune (cents) to pitch ratio
        let totalCents = interval * 100.0 + detune
        let targetRatio = powf(2.0, totalCents / 1200.0)

        // Modulation frequency: how fast the phasors sweep through the delay
        // mod_freq = (ratio - 1) * sampleRate / delaySize
        let modFreq = (targetRatio - 1.0) * sampleRate / Float(delaySize)
        let phasorIncrement = abs(modFreq) / sampleRate

        for i in 0..<sampleCount {
            let dry = buffer[i]

            // Write input into delay buffer
            delayBuffer[writeIndex] = dry
            writeIndex = (writeIndex + 1) % delaySize

            // Smooth the ratio to avoid clicks on parameter changes
            smoothedRatio += 0.0001 * (targetRatio - smoothedRatio)

            // Advance phasors (0 to 1 range)
            phasor0 += phasorIncrement
            if phasor0 >= 1.0 { phasor0 -= 1.0 }
            if phasor0 < 0.0 { phasor0 += 1.0 }

            phasor1 = phasor0 + 0.5
            if phasor1 >= 1.0 { phasor1 -= 1.0 }

            // Compute delay tap positions from phasors
            let delay0 = phasor0 * Float(delaySize)
            let delay1 = phasor1 * Float(delaySize)

            // Read from delay buffer with linear interpolation
            let tap0 = readDelay(delay0)
            let tap1 = readDelay(delay1)

            // Sinusoidal crossfade windows
            let gain0 = sinf(Float.pi * phasor0)
            let gain1 = sinf(Float.pi * phasor1)

            // Mix the two taps
            let wet = (tap0 * gain0 + tap1 * gain1) * mix

            buffer[i] = dry * (1 - dryWet) + wet * dryWet
        }
    }

    private func readDelay(_ delaySamples: Float) -> Float {
        let readPos = Float(writeIndex) - delaySamples
        let index0 = Int(readPos)
        let frac = readPos - Float(index0)
        let safeIdx0 = ((index0 % delaySize) + delaySize) % delaySize
        let safeIdx1 = (safeIdx0 + 1) % delaySize
        return delayBuffer[safeIdx0] * (1 - frac) + delayBuffer[safeIdx1] * frac
    }

    public func randomize() {
        interval = Float(Int.random(in: -7...7))
        detune = Float.random(in: -30...30)
        mix = Float.random(in: 0.3...1.0)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
