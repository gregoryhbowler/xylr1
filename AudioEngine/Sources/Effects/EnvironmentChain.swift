import Foundation

/// Per-layer environment effects chain: Reso -> Harm -> Freq -> Fuzz -> Dist -> Grain.
public final class EnvironmentChain: ObservableObject {

    public let resonator = Resonator()
    public let harmonizer = Harmonizer()
    public let frequencyShifter = FrequencyShifter()
    public let fuzz = Fuzz()
    public let distortion = Distortion()
    public let granular = GranularProcessor()

    public init() {}

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        resonator.process(buffer: buffer, sampleCount: sampleCount)
        harmonizer.process(buffer: buffer, sampleCount: sampleCount)
        frequencyShifter.process(buffer: buffer, sampleCount: sampleCount)
        fuzz.process(buffer: buffer, sampleCount: sampleCount)
        distortion.process(buffer: buffer, sampleCount: sampleCount)
        granular.process(buffer: buffer, sampleCount: sampleCount)
    }

    public func randomizeAll() {
        resonator.randomize()
        harmonizer.randomize()
        frequencyShifter.randomize()
        fuzz.randomize()
        distortion.randomize()
        granular.randomize()
    }
}
