import SwiftUI

/// Custom horizontal slider matching the XYLR1 design language.
/// White-bordered rectangle with gray fill proportional to value.
/// Min/max labels inside, orange text.
struct XSlider: View {
    let label: String
    @Binding var value: Float
    var range: ClosedRange<Float> = 0...1
    var step: Float? = nil
    var minLabel: String? = nil
    var maxLabel: String? = nil
    var formatValue: ((Float) -> String)? = nil

    private var normalizedValue: CGFloat {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        return CGFloat((value - range.lowerBound) / span)
    }

    var body: some View {
        HStack(spacing: XTheme.controlSpacing) {
            Text(label)
                .font(XTheme.labelFont)
                .foregroundColor(XTheme.primary)
                .frame(width: 80, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Border
                    Rectangle()
                        .stroke(XTheme.controlBorder, lineWidth: XTheme.borderWidth)

                    // Fill
                    Rectangle()
                        .fill(XTheme.sliderFill)
                        .frame(width: geo.size.width * normalizedValue)

                    // Min label
                    HStack {
                        Text(minLabel ?? displayMin)
                            .font(XTheme.valueFont)
                            .foregroundColor(XTheme.primary)
                            .padding(.leading, 4)
                        Spacer()
                        Text(maxLabel ?? displayMax)
                            .font(XTheme.valueFont)
                            .foregroundColor(XTheme.primary)
                            .padding(.trailing, 4)
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            let fraction = Float(drag.location.x / geo.size.width)
                            let clamped = max(0, min(1, fraction))
                            let span = range.upperBound - range.lowerBound
                            var newValue = range.lowerBound + clamped * span
                            if let step = step {
                                newValue = (newValue / step).rounded() * step
                            }
                            value = max(range.lowerBound, min(range.upperBound, newValue))
                        }
                )
            }
            .frame(height: XTheme.sliderHeight)
        }
    }

    private var displayMin: String {
        formatValue?(range.lowerBound) ?? String(format: "%.0f", range.lowerBound)
    }

    private var displayMax: String {
        formatValue?(range.upperBound) ?? String(format: "%.0f", range.upperBound)
    }
}
