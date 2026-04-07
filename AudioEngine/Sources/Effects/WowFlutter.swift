import Foundation

/// Tape-style wow and flutter (pitch/speed modulation).
public final class WowFlutter: ObservableObject {
    @Published public var dryWet: Float = 0
    @Published public var wowRate: Float = 0.5
    @Published public var wowDepth: Float = 0.3
    @Published public var flutterRate: Float = 6.0
    @Published public var flutterDepth: Float = 0.1

    private var delayBuffer: [Float] = Array(repeating: 0, count: 8192)
    private var writeIndex = 0
    private var wowPhase: Float = 0
    private var flutterPhase: Float = 0

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        let sr: Float = 44100
        for i in 0..<sampleCount {
            wowPhase += wowRate / sr
            flutterPhase += flutterRate / sr
            if wowPhase >= 1 { wowPhase -= 1 }
            if flutterPhase >= 1 { flutterPhase -= 1 }

            let mod = sin(wowPhase * .pi * 2) * wowDepth * 0.002 * sr
                    + sin(flutterPhase * .pi * 2) * flutterDepth * 0.0005 * sr

            delayBuffer[writeIndex % delayBuffer.count] = buffer[i]
            let readPos = Float(writeIndex) - 100 - mod
            let idx = (Int(readPos) % delayBuffer.count + delayBuffer.count) % delayBuffer.count
            let wet = delayBuffer[idx]

            buffer[i] = buffer[i] * (1 - dryWet) + wet * dryWet
            writeIndex += 1
        }
    }

    public func randomize() {
        wowRate = Float.random(in: 0.1...2.0)
        wowDepth = Float.random(in: 0.05...0.5)
        flutterRate = Float.random(in: 3...12)
        flutterDepth = Float.random(in: 0.02...0.2)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
