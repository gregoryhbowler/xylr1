import Foundation

/// Buffer stutter/repeat/reverse glitch effect.
public final class Glitch: ObservableObject {
    @Published public var dryWet: Float = 0
    @Published public var rate: Float = 4.0
    @Published public var size: Float = 0.1     // buffer capture size (seconds)
    @Published public var repeatCount: Int = 2

    private var captureBuffer: [Float] = Array(repeating: 0, count: 44100)
    private var readIndex = 0
    private var writeIndex = 0
    private var isGlitching = false

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        for i in 0..<sampleCount {
            let dry = buffer[i]
            captureBuffer[writeIndex % captureBuffer.count] = dry
            writeIndex += 1
            if isGlitching {
                let wet = captureBuffer[readIndex % captureBuffer.count]
                readIndex += 1
                buffer[i] = dry * (1 - dryWet) + wet * dryWet
            }
        }
    }

    public func randomize() {
        rate = Float.random(in: 1...16)
        size = Float.random(in: 0.02...0.5)
        repeatCount = Int.random(in: 1...8)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
