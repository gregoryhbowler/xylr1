import Foundation

/// Pitch-shifting harmonizer (in-key intervals).
public final class Harmonizer: ObservableObject {
    @Published public var dryWet: Float = 0
    @Published public var interval: Float = 0    // scale degrees
    @Published public var detune: Float = 0
    @Published public var mix: Float = 0.5

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        // Placeholder — pitch shifting requires a proper granular/phase-vocoder approach
        // For now, pass through with dry/wet mix
    }

    public func randomize() {
        interval = Float(Int.random(in: -7...7))
        detune = Float.random(in: -0.5...0.5)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
