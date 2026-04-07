import SwiftUI

/// Rotary knob — white circle outline with indicator line.
struct XKnob: View {
    let label: String
    @Binding var value: Float
    var range: ClosedRange<Float> = 0...1

    private let startAngle: Double = 225
    private let endAngle: Double = -45
    private let totalRotation: Double = 270

    private var normalizedValue: Double {
        let span = Double(range.upperBound - range.lowerBound)
        guard span > 0 else { return 0 }
        return Double(value - range.lowerBound) / span
    }

    private var indicatorAngle: Angle {
        .degrees(startAngle - normalizedValue * totalRotation)
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Outer circle
                Circle()
                    .stroke(XTheme.controlBorder, lineWidth: XTheme.borderWidth)

                // Indicator line
                let lineEnd = CGPoint(
                    x: cos(indicatorAngle.radians),
                    y: -sin(indicatorAngle.radians)
                )
                Path { path in
                    path.move(to: CGPoint(x: 0.5, y: 0.5))
                    path.addLine(to: CGPoint(
                        x: 0.5 + lineEnd.x * 0.4,
                        y: 0.5 + lineEnd.y * 0.4
                    ))
                }
                .stroke(XTheme.controlBorder, lineWidth: 2)
                .drawingGroup()
            }
            .frame(width: XTheme.knobSize, height: XTheme.knobSize)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        // Vertical drag to change value
                        let delta = Float(-drag.translation.height / 150)
                        let span = range.upperBound - range.lowerBound
                        value = max(range.lowerBound, min(range.upperBound, value + delta * span))
                    }
            )

            Text(label)
                .font(XTheme.valueFont)
                .foregroundColor(XTheme.primary)
        }
    }
}
