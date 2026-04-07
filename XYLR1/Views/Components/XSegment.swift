import SwiftUI

/// Segmented selector — row of white-bordered rectangles with orange labels.
/// Active segment has inverted (white fill) appearance.
struct XSegment<T: Hashable>: View {
    let label: String
    let options: [(value: T, label: String)]
    @Binding var selected: T

    var body: some View {
        HStack(spacing: XTheme.controlSpacing) {
            if !label.isEmpty {
                Text(label)
                    .font(XTheme.labelFont)
                    .foregroundColor(XTheme.primary)
                    .frame(width: 80, alignment: .leading)
            }

            HStack(spacing: 0) {
                ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                    Button {
                        selected = option.value
                    } label: {
                        Text(option.label)
                            .font(XTheme.valueFont)
                            .foregroundColor(
                                selected == option.value ? XTheme.background : XTheme.primary
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: XTheme.segmentHeight)
                            .background(
                                selected == option.value ? XTheme.controlBorder : Color.clear
                            )
                            .overlay(
                                Rectangle()
                                    .stroke(XTheme.controlBorder, lineWidth: XTheme.borderWidth)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
