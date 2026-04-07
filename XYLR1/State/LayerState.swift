import SwiftUI

/// Scale/mode definitions.
enum ScaleMode: String, CaseIterable, Codable {
    case major = "MAJOR"
    case minor = "MINOR"
    case harmonicMinor = "H MINOR"
    case melodicMinor = "M MINOR"
    case dorian = "DORIAN"
    case phrygian = "PHRYGIAN"
    case lydian = "LYDIAN"
    case mixolydian = "MIXO"
    case aeolian = "AEOLIAN"
    case locrian = "LOCRIAN"
    case wholeTone = "WHOLE"
    case pentatonicMajor = "PENT MAJ"
    case pentatonicMinor = "PENT MIN"
    case blues = "BLUES"
    case chromatic = "CHROMATIC"
    case hungarianMinor = "HUNGARIAN"
    case hirajoshi = "HIRAJOSHI"
    case inSen = "IN SEN"
    case iwato = "IWATO"

    /// Intervals from root (in semitones).
    var intervals: [Int] {
        switch self {
        case .major:           return [0, 2, 4, 5, 7, 9, 11]
        case .minor:           return [0, 2, 3, 5, 7, 8, 10]
        case .harmonicMinor:   return [0, 2, 3, 5, 7, 8, 11]
        case .melodicMinor:    return [0, 2, 3, 5, 7, 9, 11]
        case .dorian:          return [0, 2, 3, 5, 7, 9, 10]
        case .phrygian:        return [0, 1, 3, 5, 7, 8, 10]
        case .lydian:          return [0, 2, 4, 6, 7, 9, 11]
        case .mixolydian:      return [0, 2, 4, 5, 7, 9, 10]
        case .aeolian:         return [0, 2, 3, 5, 7, 8, 10]
        case .locrian:         return [0, 1, 3, 5, 6, 8, 10]
        case .wholeTone:       return [0, 2, 4, 6, 8, 10]
        case .pentatonicMajor: return [0, 2, 4, 7, 9]
        case .pentatonicMinor: return [0, 3, 5, 7, 10]
        case .blues:           return [0, 3, 5, 6, 7, 10]
        case .chromatic:       return Array(0...11)
        case .hungarianMinor:  return [0, 2, 3, 6, 7, 8, 11]
        case .hirajoshi:       return [0, 2, 3, 7, 8]
        case .inSen:           return [0, 1, 5, 7, 10]
        case .iwato:           return [0, 1, 5, 6, 10]
        }
    }
}

/// Root note.
enum RootNote: Int, CaseIterable, Codable {
    case c = 0, cSharp, d, dSharp, e, f, fSharp, g, gSharp, a, aSharp, b

    var displayName: String {
        switch self {
        case .c: return "C"
        case .cSharp: return "C#"
        case .d: return "D"
        case .dSharp: return "D#"
        case .e: return "E"
        case .f: return "F"
        case .fSharp: return "F#"
        case .g: return "G"
        case .gSharp: return "G#"
        case .a: return "A"
        case .aSharp: return "A#"
        case .b: return "B"
        }
    }
}

/// Glyph shape types for the note canvas.
enum GlyphShape: Int, CaseIterable {
    case asterisk, flower6, flower8, snowflake, star4, star6, star8, burst, diamond, cross

    /// SF Symbol name or custom shape identifier.
    var symbolName: String {
        switch self {
        case .asterisk:  return "asterisk"
        case .flower6:   return "flower6"
        case .flower8:   return "flower8"
        case .snowflake: return "snowflake"
        case .star4:     return "star4"
        case .star6:     return "star6"
        case .star8:     return "star8"
        case .burst:     return "burst"
        case .diamond:   return "diamond"
        case .cross:     return "cross"
        }
    }
}

/// A single note glyph on the canvas.
struct NoteGlyph: Identifiable {
    let id = UUID()
    let midiNote: UInt8
    let degreeName: String
    let glyphType: GlyphShape
    var position: CGPoint    // normalized 0...1
    var size: CGFloat        // normalized
}

/// Complete state for a single layer.
struct LayerState: Identifiable {
    let id = UUID()
    let index: Int

    // Scale / key
    var rootNote: RootNote = .c
    var scaleMode: ScaleMode = .major
    var octaveRange: Int = 3        // 2, 3, or 4 octaves
    var baseOctave: Int = 3         // starting octave

    // Glyph layout
    var glyphs: [NoteGlyph] = []

    // Synth parameters
    var model: Int = 1
    var harmonics: Float = 0.5
    var timbre: Float = 0.5
    var morph: Float = 0.5
    var cutoff: Float = 20000
    var resonance: Float = 0
    var attackTime: Float = 0.01
    var decayTime: Float = 0.1
    var sustainLevel: Float = 0.8
    var releaseTime: Float = 0.3
    var monoMode: Bool = false

    // Groups (active state)
    var activeGroups: Set<Int> = []
    var recordingGroup: Int? = nil

    // Tempo
    var tempoNumerator: Int = 1
    var tempoDenominator: Int = 1

    // Undo snapshot
    var undoSnapshot: LayerState? = nil

    // MARK: - Note Generation

    mutating func generateGlyphs() {
        var notes: [NoteGlyph] = []
        let root = UInt8(rootNote.rawValue)
        let startNote = UInt8(baseOctave * 12 + Int(root))

        for octave in 0..<octaveRange {
            for interval in scaleMode.intervals {
                let midiNote = startNote + UInt8(octave * 12 + interval)
                guard midiNote <= 127 else { continue }

                let noteName = Self.noteName(for: midiNote)
                let glyph = NoteGlyph(
                    midiNote: midiNote,
                    degreeName: noteName,
                    glyphType: GlyphShape.allCases.randomElement()!,
                    position: CGPoint(
                        x: CGFloat.random(in: 0.05...0.95),
                        y: CGFloat.random(in: 0.05...0.95)
                    ),
                    size: [0.03, 0.05, 0.08].randomElement()!
                )
                notes.append(glyph)
            }
        }
        glyphs = notes
    }

    static func noteName(for midiNote: UInt8) -> String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let octave = Int(midiNote) / 12 - 1
        let name = noteNames[Int(midiNote) % 12]
        return "\(name)\(octave)"
    }
}
