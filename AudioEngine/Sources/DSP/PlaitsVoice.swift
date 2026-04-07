import Foundation

/// A single synthesizer voice: Plaits DSP + ADSR envelope + SVF filter.
public final class PlaitsVoice {

    public let plaits = PlaitsWrapper()
    public let envelope = Envelope()
    public let filter = SVFilter()

    public private(set) var isActive = false
    public private(set) var midiNote: UInt8 = 0

    public init() {}

    public func noteOn(midiNote: UInt8, velocity: UInt8) {
        self.midiNote = midiNote
        self.isActive = true
        let frequency = Self.midiNoteToFrequency(midiNote)
        plaits.setFrequency(frequency)
        envelope.gate(on: true)
    }

    public func noteOff() {
        envelope.gate(on: false)
    }

    /// Render this voice into the buffer. Returns true if still active.
    @discardableResult
    public func render(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) -> Bool {
        guard isActive else { return false }

        // Render Plaits DSP
        plaits.render(buffer: buffer, sampleCount: sampleCount)

        // Apply ADSR envelope
        for i in 0..<sampleCount {
            let env = envelope.process()
            buffer[i] *= env
            if envelope.isIdle {
                isActive = false
                // Zero remaining samples
                for j in (i + 1)..<sampleCount {
                    buffer[j] = 0
                }
                return false
            }
        }

        // Apply SVF filter
        filter.process(buffer: buffer, sampleCount: sampleCount)

        return true
    }

    public static func midiNoteToFrequency(_ note: UInt8) -> Float {
        440.0 * powf(2.0, (Float(note) - 69.0) / 12.0)
    }
}
