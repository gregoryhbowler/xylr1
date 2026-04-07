import SwiftUI

/// Styled action button — white-bordered rectangle with orange text.
/// Variants: normal (outlined), filled (like UNDO).
struct XButton: View {
    let title: String
    var style: ButtonStyle = .outlined
    var action: () -> Void

    enum ButtonStyle {
        case outlined   // white border, orange text
        case filled     // orange background, white text (UNDO style)
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(XTheme.labelFont)
                .foregroundColor(textColor)
                .padding(.horizontal, 12)
                .frame(height: XTheme.buttonHeight)
                .background(backgroundColor)
                .overlay(
                    Rectangle()
                        .stroke(XTheme.controlBorder, lineWidth: XTheme.borderWidth)
                )
        }
        .buttonStyle(.plain)
    }

    private var textColor: Color {
        switch style {
        case .outlined: return XTheme.primary
        case .filled: return XTheme.undoForeground
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .outlined: return .clear
        case .filled: return XTheme.undoBackground
        }
    }
}
