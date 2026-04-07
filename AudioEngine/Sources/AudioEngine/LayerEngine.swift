import Foundation
import Combine

/// Per-layer audio engine: manages voices, arpeggiator, groups, FX chains.
public final class LayerEngine: ObservableObject, Identifiable {

    public let id = UUID()
    public let index: Int

    // MARK: - Components

    public let voiceAllocator: VoiceAllocator
    public let arpeggiator: Arpeggiator
    public let groupManager: GroupManager
    public let lfo1: LFO
    public let lfo2: LFO
    public let delayEngine = DelayEngine()
    public let animationFX = AnimationFXChain()
    public let environmentFX = EnvironmentChain()
    public let loopRecorder = LoopRecorder()

    // MARK: - Tempo

    public var tempoRatio: TempoRatio
    private weak var masterClock: MasterClock?

    public var effectiveBPM: Double {
        guard let master = masterClock else { return 120 }
        return tempoRatio.effectiveBPM(masterBPM: master.bpm)
    }

    // MARK: - Synth parameters

    @Published public var model: Int = 1
    @Published public var harmonics: Float = 0.5
    @Published public var timbre: Float = 0.5
    @Published public var morph: Float = 0.5
    @Published public var cutoff: Float = 20000
    @Published public var resonance: Float = 0
    @Published public var attackTime: Float = 0.01
    @Published public var decayTime: Float = 0.1
    @Published public var sustainLevel: Float = 0.8
    @Published public var releaseTime: Float = 0.3

    // MARK: - Mono mode

    @Published public var monoMode: Bool = false

    // MARK: - Init

    public init(index: Int, masterClock: MasterClock, tempoRatio: TempoRatio) {
        self.index = index
        self.masterClock = masterClock
        self.tempoRatio = tempoRatio
        self.voiceAllocator = VoiceAllocator(voiceCount: AudioEngine.voicesPerLayer)
        self.arpeggiator = Arpeggiator()
        self.groupManager = GroupManager()
        self.lfo1 = LFO()
        self.lfo2 = LFO()
    }

    // MARK: - Note handling

    public func noteOn(midiNote: UInt8, velocity: UInt8) {
        voiceAllocator.noteOn(midiNote: midiNote, velocity: velocity)
    }

    public func noteOff(midiNote: UInt8) {
        voiceAllocator.noteOff(midiNote: midiNote)
    }
}
