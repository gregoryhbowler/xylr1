import Foundation
import Combine

/// Per-layer audio engine: manages voices, arpeggiator, groups, FX chains.
public final class LayerEngine: ObservableObject, Identifiable {

    public let id = UUID()
    public let index: Int

    // MARK: - Components

    public let voiceAllocator: VoiceAllocator
    public let plaitsVoices: [PlaitsVoice]
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
        
        // Create Plaits voices
        var voices: [PlaitsVoice] = []
        for _ in 0..<AudioEngine.voicesPerLayer {
            voices.append(PlaitsVoice())
        }
        self.plaitsVoices = voices
        
        self.arpeggiator = Arpeggiator()
        self.groupManager = GroupManager()
        self.lfo1 = LFO()
        self.lfo2 = LFO()
    }

    // MARK: - Note handling

    public func noteOn(midiNote: UInt8, velocity: UInt8) {
        let voiceIndex = voiceAllocator.noteOn(midiNote: midiNote, velocity: velocity)
        if voiceIndex < plaitsVoices.count {
            plaitsVoices[voiceIndex].trigger(note: midiNote, velocity: velocity)
        }
    }

    public func noteOff(midiNote: UInt8) {
        voiceAllocator.noteOff(midiNote: midiNote)
        // Find and release the corresponding Plaits voice
        if let voiceIndex = plaitsVoices.firstIndex(where: { $0.midiNote == midiNote && $0.gateOn }) {
            plaitsVoices[voiceIndex].release()
        }
    }
    
    /// Render audio from all voices in this layer.
    /// - Parameters:
    ///   - outBufferL: Left channel output
    ///   - outBufferR: Right channel output
    ///   - frameCount: Number of frames to render
    public func render(outBufferL: UnsafeMutablePointer<Float>, 
                       outBufferR: UnsafeMutablePointer<Float>,
                       frameCount: Int) {
        // Zero the output buffers
        memset(outBufferL, 0, frameCount * MemoryLayout<Float>.size)
        memset(outBufferR, 0, frameCount * MemoryLayout<Float>.size)
        
        // Temporary buffer for each voice
        let voiceBuffer = UnsafeMutablePointer<Float>.allocate(capacity: frameCount)
        defer { voiceBuffer.deallocate() }
        
        // Render each active voice and mix into output
        for (index, voice) in plaitsVoices.enumerated() {
            let voiceState = voiceAllocator.voices[index]
            
            // Skip inactive voices
            guard voiceState.isActive || voice.isActive else { continue }
            
            // Render voice
            voice.render(
                outBuffer: voiceBuffer,
                auxBuffer: nil,
                frameCount: frameCount,
                engine: model,
                harmonics: harmonics,
                timbre: timbre,
                morph: morph,
                decay: decayTime,
                lpgColour: 0.5
            )
            
            // Mix into stereo output (simple centered placement for now)
            let pan: Float = 0.5 // Center pan
            let leftGain = sqrt(1.0 - pan)
            let rightGain = sqrt(pan)
            
            for i in 0..<frameCount {
                let sample = voiceBuffer[i]
                outBufferL[i] += sample * leftGain
                outBufferR[i] += sample * rightGain
            }
        }
    }
}
