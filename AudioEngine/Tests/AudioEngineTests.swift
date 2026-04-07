import XCTest
@testable import AudioEngine

final class AudioEngineTests: XCTestCase {
    func testMasterClockPulseAdvance() {
        let clock = MasterClock(sampleRate: 44100)
        clock.bpm = 120
        clock.start()

        // At 120 BPM, 96 PPQN: samples per pulse = 44100 * (60 / (120 * 96)) ≈ 229.6875
        let pulses = clock.advance(sampleCount: 230)
        XCTAssertEqual(pulses, 1)
    }

    func testTempoRatio() {
        let ratio = TempoRatio(numerator: 3, denominator: 4)
        XCTAssertEqual(ratio.effectiveBPM(masterBPM: 120), 90)
    }

    func testVoiceAllocatorStealing() {
        let allocator = VoiceAllocator(voiceCount: 2)
        allocator.noteOn(midiNote: 60, velocity: 100)
        allocator.noteOn(midiNote: 64, velocity: 100)
        // Third note should steal oldest
        let stolen = allocator.noteOn(midiNote: 67, velocity: 100)
        XCTAssertEqual(stolen, 0) // oldest was index 0
        XCTAssertEqual(allocator.voices[0].midiNote, 67)
    }
}
