import Foundation

/// Manages synth presets (factory + user).
final class PresetManager: ObservableObject {

    struct Preset: Codable, Identifiable {
        var id: String { name }
        let name: String
        let model: Int
        let harmonics: Float
        let timbre: Float
        let morph: Float
        let cutoff: Float
        let resonance: Float
        let attackTime: Float
        let decayTime: Float
        let sustainLevel: Float
        let releaseTime: Float
        let isFactory: Bool
    }

    @Published var presets: [Preset] = []
    @Published var selectedPreset: Preset?

    init() {
        loadFactoryPresets()
    }

    func loadFactoryPresets() {
        // Factory presets — initial set
        presets = [
            Preset(name: "Init Pad", model: 1, harmonics: 0.3, timbre: 0.5, morph: 0.2,
                   cutoff: 8000, resonance: 0.1, attackTime: 0.3, decayTime: 0.5,
                   sustainLevel: 0.7, releaseTime: 1.0, isFactory: true),
            Preset(name: "FM Bell", model: 3, harmonics: 0.7, timbre: 0.4, morph: 0.1,
                   cutoff: 12000, resonance: 0, attackTime: 0.001, decayTime: 1.5,
                   sustainLevel: 0, releaseTime: 0.5, isFactory: true),
            Preset(name: "Grain Cloud", model: 9, harmonics: 0.5, timbre: 0.8, morph: 0.6,
                   cutoff: 15000, resonance: 0.2, attackTime: 0.1, decayTime: 0.3,
                   sustainLevel: 0.5, releaseTime: 0.8, isFactory: true),
            Preset(name: "Modal Pluck", model: 13, harmonics: 0.4, timbre: 0.6, morph: 0.3,
                   cutoff: 10000, resonance: 0.15, attackTime: 0.001, decayTime: 0.8,
                   sustainLevel: 0, releaseTime: 0.3, isFactory: true),
            Preset(name: "Analog Kick", model: 14, harmonics: 0.5, timbre: 0.7, morph: 0.4,
                   cutoff: 5000, resonance: 0, attackTime: 0.001, decayTime: 0.3,
                   sustainLevel: 0, releaseTime: 0.1, isFactory: true),
            Preset(name: "Chord Wash", model: 7, harmonics: 0.6, timbre: 0.3, morph: 0.5,
                   cutoff: 6000, resonance: 0.3, attackTime: 0.5, decayTime: 1.0,
                   sustainLevel: 0.6, releaseTime: 2.0, isFactory: true),
            Preset(name: "Speech", model: 8, harmonics: 0.5, timbre: 0.5, morph: 0.5,
                   cutoff: 20000, resonance: 0, attackTime: 0.01, decayTime: 0.2,
                   sustainLevel: 0.8, releaseTime: 0.3, isFactory: true),
            Preset(name: "Noise Hit", model: 11, harmonics: 0.3, timbre: 0.9, morph: 0.7,
                   cutoff: 8000, resonance: 0.4, attackTime: 0.001, decayTime: 0.1,
                   sustainLevel: 0, releaseTime: 0.05, isFactory: true),
        ]
    }

    func applyPreset(_ preset: Preset, to layer: inout LayerState) {
        layer.model = preset.model
        layer.harmonics = preset.harmonics
        layer.timbre = preset.timbre
        layer.morph = preset.morph
        layer.cutoff = preset.cutoff
        layer.resonance = preset.resonance
        layer.attackTime = preset.attackTime
        layer.decayTime = preset.decayTime
        layer.sustainLevel = preset.sustainLevel
        layer.releaseTime = preset.releaseTime
    }

    func saveUserPreset(name: String, from layer: LayerState) {
        let preset = Preset(
            name: name,
            model: layer.model,
            harmonics: layer.harmonics,
            timbre: layer.timbre,
            morph: layer.morph,
            cutoff: layer.cutoff,
            resonance: layer.resonance,
            attackTime: layer.attackTime,
            decayTime: layer.decayTime,
            sustainLevel: layer.sustainLevel,
            releaseTime: layer.releaseTime,
            isFactory: false
        )
        presets.append(preset)
    }
}
