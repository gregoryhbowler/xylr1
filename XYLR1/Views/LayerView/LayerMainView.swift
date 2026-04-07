import SwiftUI

/// Main layer view — glyph canvas with header controls and bottom bar.
struct LayerMainView: View {
    @EnvironmentObject var appState: AppState

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
                    // Key/scale picker
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
                    // BPM picker
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
                // Play note via audio engine
                print("Note tap: \(midiNote)")
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
    }
}
