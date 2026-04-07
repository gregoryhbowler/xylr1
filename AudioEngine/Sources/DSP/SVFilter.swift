import Foundation

/// State-variable filter (low-pass, high-pass, band-pass) for post-Plaits filtering.
public final class SVFilter {

    public var cutoff: Float = 20000  // Hz
    public var resonance: Float = 0   // 0-1
    public var mode: FilterMode = .lowPass

    public enum FilterMode: Int, CaseIterable {
        case lowPass, highPass, bandPass
    }

    private var ic1eq: Float = 0
    private var ic2eq: Float = 0

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        let sampleRate: Float = 44100
        let g = tan(.pi * min(cutoff, sampleRate * 0.499) / sampleRate)
        let k = 2.0 - 2.0 * min(resonance, 0.99)

        for i in 0..<sampleCount {
            let v0 = buffer[i]
            let v3 = v0 - ic2eq
            let v1 = ic1eq + g * (v3 - ic1eq) / (1 + g * (g + k))
            let v2 = ic2eq + g * v1

            ic1eq = 2 * v1 - ic1eq
            ic2eq = 2 * v2 - ic2eq

            switch mode {
            case .lowPass:
                buffer[i] = v2
            case .highPass:
                buffer[i] = v0 - k * v1 - v2
            case .bandPass:
                buffer[i] = v1
            }
        }
    }

    public func reset() {
        ic1eq = 0
        ic2eq = 0
    }
}
