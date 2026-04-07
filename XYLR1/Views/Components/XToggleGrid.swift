import SwiftUI

/// Grid of toggle buttons (e.g., Group 1-8).
/// Small white-bordered squares with number labels. Active = filled.
struct XToggleGrid: View {
    let count: Int
    @Binding var activeIndices: Set<Int>
    var onToggle: ((Int) -> Void)? = nil

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...count, id: \.self) { index in
                Button {
                    if activeIndices.contains(index) {
                        activeIndices.remove(index)
                    } else {
                        activeIndices.insert(index)
                    }
                    onToggle?(index)
                } label: {
                    Text("\(index)")
                        .font(XTheme.valueFont)
                        .foregroundColor(
                            activeIndices.contains(index) ? XTheme.background : XTheme.controlBorder
                        )
                        .frame(width: XTheme.toggleSize, height: XTheme.toggleSize)
                        .background(
                            activeIndices.contains(index) ? XTheme.controlBorder : Color.clear
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
