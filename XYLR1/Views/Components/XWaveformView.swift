import SwiftUI

/// Waveform display — white waveform inside white-bordered rectangle on blue bg.
struct XWaveformView: View {
    let samples: [Float]
    var playbackPosition: CGFloat = 0  // 0-1

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Border
                Rectangle()
                    .stroke(XTheme.controlBorder, lineWidth: XTheme.borderWidth)

                // Waveform path
                if !samples.isEmpty {
                    Path { path in
                        let width = geo.size.width
                        let height = geo.size.height
                        let midY = height / 2
                        let step = max(1, samples.count / Int(width))

                        path.move(to: CGPoint(x: 0, y: midY))

                        for x in 0..<Int(width) {
                            let sampleIndex = min(x * step, samples.count - 1)
                            let sample = CGFloat(samples[sampleIndex])
                            let y = midY - sample * midY * 0.9
                            path.addLine(to: CGPoint(x: CGFloat(x), y: y))
                        }
                    }
                    .stroke(XTheme.controlBorder, lineWidth: 1)
                } else {
                    // Empty state — show center line
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geo.size.height / 2))
                        path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height / 2))
                    }
                    .stroke(XTheme.controlBorder.opacity(0.3), lineWidth: 0.5)
                }

                // Playback position indicator
                if playbackPosition > 0 {
                    Rectangle()
                        .fill(XTheme.primary)
                        .frame(width: 1)
                        .offset(x: (playbackPosition - 0.5) * geo.size.width)
                }
            }
        }
        .frame(height: 60)
    }
}
