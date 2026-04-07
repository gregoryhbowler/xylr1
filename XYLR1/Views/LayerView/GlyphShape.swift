import SwiftUI

/// Decorative glyph shapes for the note canvas.
/// Each shape is drawn as a custom SwiftUI path.
struct GlyphShapeView: View {
    let shape: GlyphShape
    let size: CGFloat

    var body: some View {
        switch shape {
        case .asterisk:
            AsteriskShape()
                .stroke(Color.white, lineWidth: max(1, size * 0.05))
                .frame(width: size, height: size)
        case .flower6:
            FlowerShape(petalCount: 6)
                .fill(Color.white)
                .frame(width: size, height: size)
        case .flower8:
            FlowerShape(petalCount: 8)
                .fill(Color.white)
                .frame(width: size, height: size)
        case .snowflake:
            SnowflakeShape()
                .stroke(Color.white, lineWidth: max(1, size * 0.04))
                .frame(width: size, height: size)
        case .star4:
            StarShape(points: 4)
                .fill(Color.white)
                .frame(width: size, height: size)
        case .star6:
            StarShape(points: 6)
                .fill(Color.white)
                .frame(width: size, height: size)
        case .star8:
            StarShape(points: 8)
                .fill(Color.white)
                .frame(width: size, height: size)
        case .burst:
            BurstShape()
                .fill(Color.white)
                .frame(width: size, height: size)
        case .diamond:
            DiamondShape()
                .fill(Color.white)
                .frame(width: size, height: size)
        case .cross:
            CrossShape()
                .fill(Color.white)
                .frame(width: size, height: size)
        }
    }
}

// MARK: - Shape Definitions

struct AsteriskShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        for i in 0..<6 {
            let angle = Double(i) * .pi / 3
            let start = CGPoint(
                x: center.x + cos(angle) * radius * 0.1,
                y: center.y + sin(angle) * radius * 0.1
            )
            let end = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            path.move(to: start)
            path.addLine(to: end)
        }
        return path
    }
}

struct FlowerShape: Shape {
    let petalCount: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        for i in 0..<petalCount {
            let angle = Double(i) * (2 * .pi) / Double(petalCount)
            let petalCenter = CGPoint(
                x: center.x + cos(angle) * radius * 0.45,
                y: center.y + sin(angle) * radius * 0.45
            )
            path.addEllipse(in: CGRect(
                x: petalCenter.x - radius * 0.35,
                y: petalCenter.y - radius * 0.35,
                width: radius * 0.7,
                height: radius * 0.7
            ))
        }
        // Center dot
        path.addEllipse(in: CGRect(
            x: center.x - radius * 0.15,
            y: center.y - radius * 0.15,
            width: radius * 0.3,
            height: radius * 0.3
        ))
        return path
    }
}

struct SnowflakeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        for i in 0..<6 {
            let angle = Double(i) * .pi / 3
            // Main branch
            let end = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            path.move(to: center)
            path.addLine(to: end)

            // Side branches
            let branchPoint = CGPoint(
                x: center.x + cos(angle) * radius * 0.5,
                y: center.y + sin(angle) * radius * 0.5
            )
            for side in [-1.0, 1.0] {
                let branchAngle = angle + side * .pi / 3
                let branchEnd = CGPoint(
                    x: branchPoint.x + cos(branchAngle) * radius * 0.3,
                    y: branchPoint.y + sin(branchAngle) * radius * 0.3
                )
                path.move(to: branchPoint)
                path.addLine(to: branchEnd)
            }
        }
        return path
    }
}

struct StarShape: Shape {
    let points: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4

        for i in 0..<(points * 2) {
            let angle = Double(i) * .pi / Double(points) - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct BurstShape: Shape {
    func path(in rect: CGRect) -> Path {
        StarShape(points: 12).path(in: rect)
    }
}

struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct CrossShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width * 0.25
        path.addRect(CGRect(x: rect.midX - w/2, y: rect.minY, width: w, height: rect.height))
        path.addRect(CGRect(x: rect.minX, y: rect.midY - w/2, width: rect.width, height: w))
        return path
    }
}
