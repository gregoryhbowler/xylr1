import Foundation

/// Granular processing effect for the Environment chain.
public final class GranularProcessor: ObservableObject {
    @Published public var dryWet: Float = 0
    @Published public var grainSize: Float = 0.05     // seconds
    @Published public var density: Float = 0.5
    @Published public var pitch: Float = 0            // semitones offset
    @Published public var position: Float = 0.5
    @Published public var spray: Float = 0
    @Published public var feedback: Float = 0

    private var buffer: [Float] = Array(repeating: 0, count: 88200) // 2 seconds
    private var writeIndex = 0

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        // Granular processing placeholder — capture input into circular buffer
        for i in 0..<sampleCount {
            self.buffer[writeIndex] = buffer[i]
            writeIndex = (writeIndex + 1) % self.buffer.count
        }
    }

    public func randomize() {
        grainSize = Float.random(in: 0.01...0.2)
        density = Float.random(in: 0.1...1.0)
        pitch = Float(Int.random(in: -12...12))
        spray = Float.random(in: 0...1)
        feedback = Float.random(in: 0...0.8)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
