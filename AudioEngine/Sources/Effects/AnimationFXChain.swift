import Foundation

/// Per-layer animation effects chain: Phaser -> Flanger -> Chorus -> Tremolo.
/// Each effect has independent dry/wet control.
public final class AnimationFXChain: ObservableObject {

    public let phaser = Phaser()
    public let flanger = Flanger()
    public let chorus = Chorus()
    public let tremolo = Tremolo()

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        phaser.process(buffer: buffer, sampleCount: sampleCount)
        flanger.process(buffer: buffer, sampleCount: sampleCount)
        chorus.process(buffer: buffer, sampleCount: sampleCount)
        tremolo.process(buffer: buffer, sampleCount: sampleCount)
    }

    public func randomizeAll() {
        phaser.randomize()
        flanger.randomize()
        chorus.randomize()
        tremolo.randomize()
    }
}
