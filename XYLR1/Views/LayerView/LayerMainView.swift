import SwiftUI

/// Main layer view — glyph canvas with header controls and bottom bar.
struct LayerMainView: View {
    @EnvironmentObject var appState: AppState
    @State private var showKeyPicker = false
    @State private var showBPMPicker = false

    var body: some View {
        let layerBinding = Binding<LayerState>(
            get: { appState.activeLayer },
            set: { appState.layers[appState.activeLayerIndex] = $0 }
        )

        VStack(spacing: 0) {
            // Header
            HStack {
                Text("LAYER \(appState.activeLayerIndex + 1)")
                    .font(XTheme.titleFont)
                    .foregroundColor(XTheme.primary)

                Spacer()

                // Add layer button
                if appState.layers.count < 4 {
                    Button {
                        appState.addLayer()
                    } label: {
                        Text("+")
                            .font(XTheme.titleFont)
                            .foregroundColor(XTheme.primary)
                    }
                    .buttonStyle(.plain)
                }

                // Audio record button
                Button {
                    appState.isRecordingOutput.toggle()
                } label: {
                    Circle()
                        .stroke(XTheme.primary, lineWidth: 2)
                        .overlay(
                            Circle()
                                .fill(appState.isRecordingOutput ? Color.red : Color.clear)
                                .padding(4)
                        )
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, XTheme.viewPadding)
            .padding(.top, 8)

            // Key / BPM / Synth selectors
            HStack(spacing: 0) {
                Button {
                    showKeyPicker = true
                } label: {
                    Text("\(layerBinding.wrappedValue.rootNote.displayName) \(layerBinding.wrappedValue.scaleMode.rawValue)")
                        .font(XTheme.labelFont)
                        .foregroundColor(XTheme.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: XTheme.segmentHeight)
                        .overlay(
                            Rectangle().stroke(XTheme.controlBorder, lineWidth: XTheme.borderWidth)
                        )
                }
                .buttonStyle(.plain)

                Button {
                    showBPMPicker = true
                } label: {
                    Text("\(Int(appState.masterBPM)) BPM")
                        .font(XTheme.labelFont)
                        .foregroundColor(XTheme.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: XTheme.segmentHeight)
                        .overlay(
                            Rectangle().stroke(XTheme.controlBorder, lineWidth: XTheme.borderWidth)
                        )
                }
                .buttonStyle(.plain)

                Button {
                    appState.currentView = .synth
                } label: {
                    Text("SYNTH")
                        .font(XTheme.labelFont)
                        .foregroundColor(XTheme.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: XTheme.segmentHeight)
                        .overlay(
                            Rectangle().stroke(XTheme.controlBorder, lineWidth: XTheme.borderWidth)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, XTheme.viewPadding)

            // Glyph canvas
            GlyphCanvasView(layer: layerBinding) { midiNote in
                appState.noteOn(midiNote)
                // Auto-release after a short hold (touch-based, no sustain pedal)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    appState.noteOff(midiNote)
                }
            }
            .padding(.horizontal, 8)

            // Bottom controls
            LayerControlBar(layer: layerBinding)
                .padding(.horizontal, XTheme.viewPadding)
                .padding(.bottom, 8)
        }
        .background(XTheme.background)
        .onAppear {
            if appState.activeLayer.glyphs.isEmpty {
                appState.layers[appState.activeLayerIndex].generateGlyphs()
            }
        }
        .sheet(isPresented: $showKeyPicker) {
            KeyScalePickerView(layer: layerBinding)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showBPMPicker) {
            BPMPickerView(bpm: $appState.masterBPM) {
                appState.syncBPM()
            }
            .presentationDetents([.height(200)])
        }
    }
}

// MARK: - Key/Scale Picker

struct KeyScalePickerView: View {
    @Binding var layer: LayerState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("KEY / SCALE")
                .font(XTheme.headlineFont)
                .foregroundColor(XTheme.primary)

            // Root note
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 6), spacing: 4) {
                ForEach(RootNote.allCases, id: \.self) { root in
                    Button {
                        layer.rootNote = root
                        layer.generateGlyphs()
                    } label: {
                        Text(root.displayName)
                            .font(XTheme.labelFont)
                            .foregroundColor(layer.rootNote == root ? XTheme.background : XTheme.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(layer.rootNote == root ? XTheme.controlBorder : Color.clear)
                            .overlay(Rectangle().stroke(XTheme.controlBorder, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }

            // Scale mode
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                    ForEach(ScaleMode.allCases, id: \.self) { scale in
                        Button {
                            layer.scaleMode = scale
                            layer.generateGlyphs()
                        } label: {
                            Text(scale.rawValue)
                                .font(XTheme.valueFont)
                                .foregroundColor(layer.scaleMode == scale ? XTheme.background : XTheme.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 28)
                                .background(layer.scaleMode == scale ? XTheme.controlBorder : Color.clear)
                                .overlay(Rectangle().stroke(XTheme.controlBorder, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Octave range
            HStack {
                Text("OCTAVES")
                    .font(XTheme.labelFont)
                    .foregroundColor(XTheme.primary)
                ForEach([2, 3, 4], id: \.self) { oct in
                    Button {
                        layer.octaveRange = oct
                        layer.generateGlyphs()
                    } label: {
                        Text("\(oct)")
                            .font(XTheme.labelFont)
                            .foregroundColor(layer.octaveRange == oct ? XTheme.background : XTheme.primary)
                            .frame(width: 40, height: 28)
                            .background(layer.octaveRange == oct ? XTheme.controlBorder : Color.clear)
                            .overlay(Rectangle().stroke(XTheme.controlBorder, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(XTheme.viewPadding)
        .background(XTheme.background)
    }
}

// MARK: - BPM Picker

struct BPMPickerView: View {
    @Binding var bpm: Double
    var onCommit: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("BPM")
                .font(XTheme.headlineFont)
                .foregroundColor(XTheme.primary)

            Text("\(Int(bpm))")
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(XTheme.primary)

            XSlider(
                label: "",
                value: Binding(
                    get: { Float(bpm) },
                    set: {
                        bpm = Double($0)
                        onCommit()
                    }
                ),
                range: 40...300,
                step: 1,
                minLabel: "40",
                maxLabel: "300"
            )
        }
        .padding(XTheme.viewPadding)
        .background(XTheme.background)
    }
}
