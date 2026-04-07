import SwiftUI

/// Central design system for XYLR1.
/// All colors, fonts, and dimension constants live here.
enum XTheme {

    // MARK: - Colors

    /// Klein blue background
    static let background = Color(red: 20/255, green: 0/255, blue: 224/255)

    /// Warm orange for primary text, labels, icons
    static let primary = Color(red: 232/255, green: 112/255, blue: 48/255)

    /// White for control borders, glyphs
    static let controlBorder = Color.white

    /// Light gray for slider fills / knob indicators
    static let sliderFill = Color(red: 192/255, green: 192/255, blue: 192/255)

    /// Active/selected segment background
    static let activeSegment = Color.white

    /// Undo button background (orange fill, white text)
    static let undoBackground = primary
    static let undoForeground = Color.white

    // MARK: - Fonts

    static let titleFont = Font.system(.title, design: .monospaced).bold()
    static let headlineFont = Font.system(.headline, design: .monospaced).bold()
    static let labelFont = Font.system(.caption, design: .monospaced)
    static let valueFont = Font.system(.caption2, design: .monospaced)
    static let bodyMono = Font.system(.body, design: .monospaced)

    // MARK: - Dimensions

    static let sliderHeight: CGFloat = 28
    static let sliderCornerRadius: CGFloat = 2
    static let segmentHeight: CGFloat = 28
    static let toggleSize: CGFloat = 28
    static let knobSize: CGFloat = 52
    static let buttonHeight: CGFloat = 32
    static let controlSpacing: CGFloat = 8
    static let viewPadding: CGFloat = 16
    static let borderWidth: CGFloat = 1.5
}
