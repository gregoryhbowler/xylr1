import Foundation

/// Buffer reverse effect.
public final class Reverse: ObservableObject {
    @Published public var dryWet: Float = 0
    @Published public var windowSize: Float = 0.25  // seconds

    private var captureBuffer: [Float] = Array(repeating: 0, count: 22050)
    private var writeIndex = 0
    private var readIndex = 0
    private var windowSamples = 11025

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        windowSamples = min(Int(windowSize * 44100), captureBuffer.count)
        guard windowSamples > 0 else { return }

        for i in 0..<sampleCount {
            let dry = buffer[i]
            captureBuffer[writeIndex % windowSamples] = dry
            let reverseIdx = (windowSamples - 1 - (writeIndex % windowSamples))
            let wet = captureBuffer[reverseIdx % windowSamples]
            buffer[i] = dry * (1 - dryWet) + wet * dryWet
            writeIndex += 1
        }
    }

    public func randomize() {
        windowSize = Float.random(in: 0.05...0.5)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
