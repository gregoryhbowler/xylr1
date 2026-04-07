import Foundation

/// Distortion with multiple clipping types.
public final class Distortion: ObservableObject {

    public enum ClipType: Int, CaseIterable, Codable {
        case softClip, hardClip, fold, wrap
    }

    @Published public var dryWet: Float = 0
    @Published public var drive: Float = 0.5
    @Published public var tone: Float = 0.5
    @Published public var clipType: ClipType = .softClip

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        let gain = 1.0 + drive * 10.0

        for i in 0..<sampleCount {
            let dry = buffer[i]
            var wet = dry * gain

            switch clipType {
            case .softClip:
                wet = tanh(wet)
            case .hardClip:
                wet = max(-1, min(1, wet))
            case .fold:
                while abs(wet) > 1.0 {
                    if wet > 1.0 { wet = 2.0 - wet }
                    if wet < -1.0 { wet = -2.0 - wet }
                }
            case .wrap:
                wet = wet.truncatingRemainder(dividingBy: 2.0)
                if wet > 1.0 { wet -= 2.0 }
                if wet < -1.0 { wet += 2.0 }
            }

            buffer[i] = dry * (1 - dryWet) + wet * dryWet
        }
    }

    public func randomize() {
        drive = Float.random(in: 0.1...1.0)
        tone = Float.random(in: 0...1)
        clipType = ClipType.allCases.randomElement()!
        dryWet = Float.random(in: 0.3...1.0)
    }
}
