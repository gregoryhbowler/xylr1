import Foundation

/// Swift wrapper for a single C++ Plaits voice instance.
/// Each voice can render one note at a time with independent parameters.
public final class PlaitsVoice {
    
    private var handle: OpaquePointer?
    
    // Voice state
    public var isActive: Bool = false
    public var midiNote: UInt8 = 60
    public var velocity: UInt8 = 100
    public var gateOn: Bool = false
    
    // Trigger tracking
    private var needsTrigger: Bool = false
    
    public init() {
        handle = plaits_create()
    }
    
    deinit {
        if let h = handle {
            plaits_destroy(h)
        }
    }
    
    /// Trigger a new note.
    public func trigger(note: UInt8, velocity: UInt8) {
        self.midiNote = note
        self.velocity = velocity
        self.gateOn = true
        self.isActive = true
        self.needsTrigger = true
    }
    
    /// Release the current note.
    public func release() {
        self.gateOn = false
        // Don't immediately mark inactive - let envelope decay
    }
    
    /// Render audio from this voice into the provided buffers.
    /// - Parameters:
    ///   - outBuffer: Main output buffer
    ///   - auxBuffer: Auxiliary output buffer (can be nil)
    ///   - frameCount: Number of samples to render
    ///   - engine: Plaits engine index (0-15)
    ///   - harmonics: Harmonics parameter (0-1)
    ///   - timbre: Timbre parameter (0-1)
    ///   - morph: Morph parameter (0-1)
    ///   - decay: Envelope decay (0-1)
    ///   - lpgColour: LPG colour (0-1)
    public func render(
        outBuffer: UnsafeMutablePointer<Float>,
        auxBuffer: UnsafeMutablePointer<Float>?,
        frameCount: Int,
        engine: Int,
        harmonics: Float,
        timbre: Float,
        morph: Float,
        decay: Float,
        lpgColour: Float
    ) {
        guard isActive, let handle = handle else {
            // Silence if inactive
            memset(outBuffer, 0, frameCount * MemoryLayout<Float>.size)
            if let aux = auxBuffer {
                memset(aux, 0, frameCount * MemoryLayout<Float>.size)
            }
            return
        }
        
        // Convert MIDI note to Plaits note format (60 = middle C = 0.0)
        let note = Float(midiNote) - 60.0
        
        // Velocity as level (0-1)
        let level = Float(velocity) / 127.0
        
        // Trigger value: 1.0 if we need to trigger, 0.0 otherwise
        let trigger: Float = needsTrigger ? 1.0 : 0.0
        needsTrigger = false
        
        plaits_render(
            handle,
            Int32(engine),
            note,
            harmonics,
            timbre,
            morph,
            trigger,
            gateOn ? level : -1.0, // negative level = gate off
            decay,
            lpgColour,
            outBuffer,
            auxBuffer,
            Int32(frameCount)
        )
    }
}

// MARK: - C Bridge

@_silgen_name("plaits_create")
fileprivate func plaits_create() -> OpaquePointer

@_silgen_name("plaits_destroy")
fileprivate func plaits_destroy(_ handle: OpaquePointer)

@_silgen_name("plaits_render")
fileprivate func plaits_render(
    _ handle: OpaquePointer,
    _ engine: Int32,
    _ note: Float,
    _ harmonics: Float,
    _ timbre: Float,
    _ morph: Float,
    _ trigger: Float,
    _ level: Float,
    _ decay: Float,
    _ lpgColour: Float,
    _ out: UnsafeMutablePointer<Float>,
    _ aux: UnsafeMutablePointer<Float>?,
    _ sampleCount: Int32
)
