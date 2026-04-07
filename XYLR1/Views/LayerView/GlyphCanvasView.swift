import SwiftUI

/// The randomized note field — main interactive canvas where glyphs represent notes.
struct GlyphCanvasView: View {
    @Binding var layer: LayerState
    var onNoteTap: ((UInt8) -> Void)? = nil

    @State private var tappedGlyphID: UUID? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(layer.glyphs) { glyph in
                    GlyphShapeView(
                        shape: glyph.glyphType,
                        size: glyphSize(for: glyph, in: geo.size)
                    )
                    .opacity(tappedGlyphID == glyph.id ? 0.5 : 1.0)
                    .scaleEffect(tappedGlyphID == glyph.id ? 1.2 : 1.0)
                    .position(
                        x: glyph.position.x * geo.size.width,
                        y: glyph.position.y * geo.size.height
                    )
                    .onTapGesture {
                        onNoteTap?(glyph.midiNote)
                        // Visual feedback
                        withAnimation(.easeOut(duration: 0.15)) {
                            tappedGlyphID = glyph.id
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.easeIn(duration: 0.1)) {
                                tappedGlyphID = nil
                            }
                        }
                    }
                }
            }
        }
    }

    private func glyphSize(for glyph: NoteGlyph, in containerSize: CGSize) -> CGFloat {
        let baseSize = min(containerSize.width, containerSize.height)
        return glyph.size * baseSize
    }
}
