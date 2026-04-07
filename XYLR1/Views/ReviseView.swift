import SwiftUI

/// Dual-buffer sampler / performance view.
struct ReviseView: View {
    @EnvironmentObject var appState: AppState
    @State private var showNewConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("REVISE")
                    .font(XTheme.titleFont)
                    .foregroundColor(XTheme.primary)

                Spacer()

                // Add buffer? (future)
                Text("+")
                    .font(XTheme.titleFont)
                    .foregroundColor(XTheme.primary)

                // Audio record button
                Circle()
                    .stroke(XTheme.primary, lineWidth: 2)
                    .overlay(
                        Circle()
                            .fill(appState.isRecordingOutput ? Color.red : Color.clear)
                            .padding(4)
                    )
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, XTheme.viewPadding)
            .padding(.top, 8)

            ScrollView {
                VStack(spacing: 16) {
                    // Buffer 1
                    BufferSection(
                        bufferState: Binding(
                            get: { appState.revise.buffer1 },
                            set: { appState.revise.buffer1 = $0 }
                        ),
                        title: "BUFFER 1"
                    )

                    // Buffer 2
                    BufferSection(
                        bufferState: Binding(
                            get: { appState.revise.buffer2 },
                            set: { appState.revise.buffer2 = $0 }
                        ),
                        title: "BUFFER 2"
                    )

                    // Layer performance controls
                    VStack(alignment: .leading, spacing: 8) {
                        // Layer 1
                        HStack {
                            Text("LAYER 1")
                                .font(XTheme.labelFont)
                                .foregroundColor(XTheme.primary)
                            XToggleGrid(count: 8, activeIndices: Binding(
                                get: { appState.revise.layer1ActiveGroups },
                                set: { appState.revise.layer1ActiveGroups = $0 }
                            ))
                            Spacer()
                            Text("TRANSPOSE")
                                .font(XTheme.valueFont)
                                .foregroundColor(XTheme.primary)
                            XSlider(
                                label: "",
                                value: Binding(
                                    get: { Float(appState.revise.layer1Transpose) },
                                    set: { appState.revise.layer1Transpose = Int($0) }
                                ),
                                range: -12...12, step: 1,
                                minLabel: "-12", maxLabel: "12"
                            )
                            .frame(width: 100)
                        }

                        // Layer 2
                        HStack {
                            Text("LAYER 2")
                                .font(XTheme.labelFont)
                                .foregroundColor(XTheme.primary)
                            XToggleGrid(count: 8, activeIndices: Binding(
                                get: { appState.revise.layer2ActiveGroups },
                                set: { appState.revise.layer2ActiveGroups = $0 }
                            ))
                            Spacer()
                            Text("TRANSPOSE")
                                .font(XTheme.valueFont)
                                .foregroundColor(XTheme.primary)
                            XSlider(
                                label: "",
                                value: Binding(
                                    get: { Float(appState.revise.layer2Transpose) },
                                    set: { appState.revise.layer2Transpose = Int($0) }
                                ),
                                range: -12...12, step: 1,
                                minLabel: "-12", maxLabel: "12"
                            )
                            .frame(width: 100)
                        }
                    }
                    .padding(.horizontal, XTheme.viewPadding)

                    // Action buttons
                    HStack {
                        Spacer()
                        XButton(title: "EXPORT") {
                            // TODO: render buffer to WAV and present share sheet
                        }
                        XButton(title: "SAVE") {
                            // TODO: save full project state to documents
                        }
                        XButton(title: "NEW") {
                            showNewConfirmation = true
                        }
                        Spacer()
                    }
                    .alert("New Project", isPresented: $showNewConfirmation) {
                        Button("Cancel", role: .cancel) {}
                        Button("New", role: .destructive) {
                            appState.revise = ReviseState()
                            appState.layers = [LayerState(index: 0)]
                            appState.activeLayerIndex = 0
                            appState.layers[0].generateGlyphs()
                        }
                    } message: {
                        Text("Unsaved changes will be lost.")
                    }
                    .padding(.bottom, 16)
                }
            }
        }
        .background(XTheme.background)
    }
}

/// A single buffer section in the Revise view.
struct BufferSection: View {
    @Binding var bufferState: ReviseState.BufferState
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Transport controls
            HStack {
                Text(title)
                    .font(XTheme.labelFont)
                    .foregroundColor(XTheme.primary)

                Spacer()

                HStack(spacing: 4) {
                    SmallButton(title: "rec") { bufferState.isRecording.toggle() }
                    SmallButton(title: "overdub") { bufferState.isOverdubbing.toggle() }
                    SmallButton(title: "rec pause") { bufferState.isPaused.toggle() }
                    SmallButton(title: "play pause") { bufferState.isPlaying.toggle() }
                    SmallButton(title: bufferState.isLooping ? "loop" : "1-shot") {
                        bufferState.isLooping.toggle()
                    }
                }
            }
            .padding(.horizontal, XTheme.viewPadding)

            // Waveform
            XWaveformView(samples: [], playbackPosition: 0)
                .padding(.horizontal, XTheme.viewPadding)

            // Knob rows
            HStack(spacing: 12) {
                XKnob(label: "pitch", value: $bufferState.pitch, range: -12...12)
                XKnob(label: "size", value: $bufferState.grainSize, range: 0.01...0.5)
                XKnob(label: "density", value: $bufferState.density)
                XKnob(label: "position", value: $bufferState.grainPosition)
                XKnob(label: "spread", value: $bufferState.spread)
                XKnob(label: "hpf", value: $bufferState.hpf, range: 20...20000)
                XKnob(label: "lpf", value: $bufferState.lpf, range: 20...20000)
            }
            .padding(.horizontal, XTheme.viewPadding)

            HStack(spacing: 12) {
                XKnob(label: "shape", value: $bufferState.shape)
                XKnob(label: "gain", value: $bufferState.gain, range: 0...2)
                XKnob(label: "delay", value: $bufferState.delaySend)
                XKnob(label: "time", value: $bufferState.delayTime, range: 0...2)
                XKnob(label: "fb", value: $bufferState.delayFeedback)
                XKnob(label: "verb", value: $bufferState.verbSend)
                XKnob(label: "size", value: $bufferState.verbSize)
            }
            .padding(.horizontal, XTheme.viewPadding)

            // LFO indicators + clear
            HStack {
                Text("lfo 1")
                    .font(XTheme.valueFont)
                    .foregroundColor(XTheme.primary)
                Spacer()
                Text("lfo 2")
                    .font(XTheme.valueFont)
                    .foregroundColor(XTheme.primary)
                Spacer()

                // LFO detail buttons
                ForEach(["SYNC", "DEST", "AMT", "RATE", "SYNC", "DEST", "AMT", "RATE"], id: \.self) { label in
                    Text(label)
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(XTheme.primary)
                        .padding(.horizontal, 2)
                        .overlay(Rectangle().stroke(XTheme.controlBorder, lineWidth: 0.5))
                }

                Spacer()

                Button {
                    bufferState = ReviseState.BufferState(id: bufferState.id)
                } label: {
                    Text("clear")
                        .font(XTheme.labelFont)
                        .foregroundColor(XTheme.primary)
                        .rotationEffect(.degrees(-90))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, XTheme.viewPadding)
        }
    }
}

struct SmallButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(XTheme.primary)
        }
        .buttonStyle(.plain)
    }
}
