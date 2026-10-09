#if canImport(UIKit)
    import SwiftUI

    /// Simple outline glyphs traced from the observed Code references. No private icon asset is embedded.
    @MainActor enum CodeReferenceIcons {
        enum Kind { case working, checklist, branch, model, connectors }
        static func image(_ kind: Kind) -> Image {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 24, height: 24))
            let image = renderer.image { context in
                let c = context.cgContext
                c.setStrokeColor(UIColor.black.cgColor)
                c.setLineWidth(1.55)
                c.setLineCap(.round)
                c.setLineJoin(.round)
                switch kind {
                case .working:
                    c.addArc(
                        center: CGPoint(x: 12, y: 12), radius: 8.5, startAngle: -.pi / 3, endAngle: .pi * 1.48,
                        clockwise: false)
                case .checklist:
                    for y: CGFloat in [5, 12, 19] {
                        c.move(to: CGPoint(x: 2, y: y))
                        c.addLine(to: CGPoint(x: 3.5, y: y + 1.5))
                        c.addLine(to: CGPoint(x: 6, y: y - 1.5))
                        c.move(to: CGPoint(x: 10, y: y))
                        c.addLine(to: CGPoint(x: 22, y: y))
                    }
                case .branch:
                    c.move(to: CGPoint(x: 6, y: 6))
                    c.addLine(to: CGPoint(x: 6, y: 18))
                    c.move(to: CGPoint(x: 18, y: 6))
                    c.addLine(to: CGPoint(x: 18, y: 10))
                    c.addCurve(
                        to: CGPoint(x: 6, y: 16), control1: CGPoint(x: 18, y: 16), control2: CGPoint(x: 6, y: 10))
                    for p in [CGPoint(x: 6, y: 3.5), CGPoint(x: 18, y: 3.5), CGPoint(x: 6, y: 20.5)] {
                        c.addEllipse(in: CGRect(x: p.x - 2.5, y: p.y - 2.5, width: 5, height: 5))
                    }
                case .model:
                    for angle in [-CGFloat.pi / 4, .pi / 4] {
                        c.saveGState()
                        c.translateBy(x: 12, y: 12)
                        c.rotate(by: angle)
                        c.addEllipse(in: CGRect(x: -5, y: -10, width: 10, height: 20))
                        c.strokePath()
                        c.restoreGState()
                    }
                case .connectors:
                    for r in [
                        CGRect(x: 3, y: 12, width: 8, height: 9), CGRect(x: 13, y: 12, width: 8, height: 9),
                        CGRect(x: 13, y: 2, width: 8, height: 8)
                    ] { c.addPath(UIBezierPath(roundedRect: r, cornerRadius: 1).cgPath) }
                }
                c.strokePath()
            }
            return Image(uiImage: image.withRenderingMode(.alwaysTemplate))
        }
    }
    private struct CodeWorkingIndicator: View {
        @State private var spinning = false
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        var body: some View {
            CodeReferenceIcons.image(.working).resizable().frame(width: 18, height: 18).rotationEffect(
                .degrees(spinning ? 360 : 0)
            )
            .onAppear {
                if !reduceMotion {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) { spinning = true }
                }
            }
        }
    }
    extension CodeReferenceIcons {
        static var workingIndicator: some View { CodeWorkingIndicator() }
    }
#endif
