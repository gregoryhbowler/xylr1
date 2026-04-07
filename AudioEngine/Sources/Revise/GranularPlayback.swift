import Foundation

/// Granular playback engine for ReviseBuffer.
public final class GranularPlayback {

    public struct Grain {
        var position: Int       // sample position in source
        var length: Int         // grain length in samples
        var readIndex: Int = 0
        var amplitude: Float = 1.0
        var panL: Float = 1.0
        var panR: Float = 1.0
    }

    private var grains: [Grain] = []
    private var sampleAccumulator: Float = 0

    public var grainSize: Float = 0.05     // seconds
    public var density: Float = 0.5        // grains per second factor
    public var pitch: Float = 0            // semitones
    public var position: Float = 0         // 0-1
    public var spread: Float = 0           // stereo spread
    public var shape: Float = 0.5          // window shape (0=rect, 0.5=hann, 1=gauss)

    public init() {}

    /// Process a block, reading from the source buffer.
    public func process(
        source: UnsafePointer<Float>,
        sourceLength: Int,
        output: UnsafeMutablePointer<Float>,
        sampleCount: Int
    ) {
        guard sourceLength > 0 else { return }
        let grainLengthSamples = max(1, Int(grainSize * 44100))
        let grainsPerSecond = density * 100
        let samplesPerGrain = 44100.0 / grainsPerSecond

        for i in 0..<sampleCount {
            sampleAccumulator += 1

            // Spawn new grains
            if sampleAccumulator >= Float(samplesPerGrain) {
                sampleAccumulator = 0
                let startPos = Int(position * Float(sourceLength))
                    + Int.random(in: -grainLengthSamples/2...grainLengthSamples/2)
                let safePos = max(0, min(sourceLength - grainLengthSamples, startPos))
                grains.append(Grain(
                    position: safePos,
                    length: grainLengthSamples,
                    amplitude: 1.0
                ))
            }

            // Mix active grains
            var sample: Float = 0
            grains = grains.filter { grain in
                var g = grain
                guard g.readIndex < g.length else { return false }
                let sourceIdx = g.position + g.readIndex
                guard sourceIdx >= 0, sourceIdx < sourceLength else { return false }

                // Window function (Hann)
                let windowPos = Float(g.readIndex) / Float(g.length)
                let window = 0.5 * (1.0 - cos(windowPos * 2.0 * .pi))

                sample += source[sourceIdx] * window * g.amplitude
                g.readIndex += 1
                return g.readIndex < g.length
            }

            output[i] += sample
        }
    }
}
