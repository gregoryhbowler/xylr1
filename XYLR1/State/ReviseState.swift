import Foundation

/// State for the Revise (sampler/buffer) view.
struct ReviseState {

    struct BufferState: Identifiable {
        let id: Int

        var isRecording: Bool = false
        var isOverdubbing: Bool = false
        var isPlaying: Bool = false
        var isPaused: Bool = false
        var isLooping: Bool = true
        var duration: TimeInterval = 0
        var position: TimeInterval = 0
        var hasContent: Bool = false

        // Granular parameters
        var pitch: Float = 0
        var grainSize: Float = 0.05
        var density: Float = 0.5
        var grainPosition: Float = 0
        var spread: Float = 0
        var hpf: Float = 20
        var lpf: Float = 20000
        var shape: Float = 0.5
        var gain: Float = 1.0
        var delaySend: Float = 0
        var delayTime: Float = 0.3
        var delayFeedback: Float = 0.3
        var verbSend: Float = 0
        var verbSize: Float = 0.5
    }

    var buffer1 = BufferState(id: 1)
    var buffer2 = BufferState(id: 2)

    // Per-layer performance controls
    var layer1ActiveGroups: Set<Int> = []
    var layer2ActiveGroups: Set<Int> = []
    var layer1Transpose: Int = 0   // -12 to +12
    var layer2Transpose: Int = 0   // -12 to +12
}
