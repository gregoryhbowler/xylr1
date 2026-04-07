import Foundation

/// Master bus treatment effects chain.
/// Signal flow: Gate -> Glitch -> Trem -> Wow/Flt -> Stretch -> Ring -> Reverse -> EQ -> Verb -> Sat
public final class TreatmentChain: ObservableObject {

    public let gate = Gate()
    public let glitch = Glitch()
    public let tremolo = TreatmentTremolo()
    public let wowFlutter = WowFlutter()
    public let timeStretch = TimeStretch()
    public let ringMod = RingMod()
    public let reverse = Reverse()
    public let eq = EQ()
    public let reverb = Reverb()
    public let saturation = Saturation()

    public init() {}

    /// Process the entire treatment chain.
    /// Effects with dryWet = 0 are automatically bypassed for performance.
    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        // Process only effects that are actually enabled
        // Each effect should internally check dryWet and early-return if 0
        gate.process(buffer: buffer, sampleCount: sampleCount)
        glitch.process(buffer: buffer, sampleCount: sampleCount)
        tremolo.process(buffer: buffer, sampleCount: sampleCount)
        wowFlutter.process(buffer: buffer, sampleCount: sampleCount)
        timeStretch.process(buffer: buffer, sampleCount: sampleCount)
        ringMod.process(buffer: buffer, sampleCount: sampleCount)
        reverse.process(buffer: buffer, sampleCount: sampleCount)
        eq.process(buffer: buffer, sampleCount: sampleCount)
        reverb.process(buffer: buffer, sampleCount: sampleCount)
        saturation.process(buffer: buffer, sampleCount: sampleCount)
    }

    public func randomizeAll() {
        gate.randomize()
        glitch.randomize()
        tremolo.randomize()
        wowFlutter.randomize()
        timeStretch.randomize()
        ringMod.randomize()
        reverse.randomize()
        eq.randomize()
        reverb.randomize()
        saturation.randomize()
    }
}

/// Treatment-chain tremolo (separate from Animation tremolo).
public final class TreatmentTremolo: ObservableObject {
    @Published public var dryWet: Float = 0
    @Published public var rate: Float = 4.0
    @Published public var depth: Float = 0.5
    private var phase: Float = 0

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0 else { return }
        let increment = rate / 44100.0
        for i in 0..<sampleCount {
            phase += increment
            if phase >= 1.0 { phase -= 1.0 }
            let mod = 1.0 - depth * (sin(phase * .pi * 2) + 1) * 0.5
            let wet = buffer[i] * mod
            buffer[i] = buffer[i] * (1 - dryWet) + wet * dryWet
        }
    }

    public func randomize() {
        rate = Float.random(in: 0.5...20)
        depth = Float.random(in: 0.1...1.0)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
