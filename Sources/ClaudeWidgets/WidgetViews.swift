#if os(iOS)
import SwiftUI
import WidgetKit

/// Stateless content shared by native WidgetKit timelines and the in-app preview.
public struct ClaudeWidgetContent: View {
    public let presentation: ClaudeWidgetPresentation
    public init(presentation: ClaudeWidgetPresentation) { self.presentation = presentation }
    public var body: some View {
        GeometryReader { geo in
            let height = max(0, (geo.size.height - 12) / 2)
            VStack(spacing: 12) {
                Link(destination: presentation.primary.url) {
                    HStack(spacing: 14) {
                        Image("ClaudeLogo", bundle: .module).resizable().scaledToFit().frame(width: 22, height: 22)
                        Text(presentation.layout == .quickActionsMedium ? "How can I help you today?" : presentation.primary.title).font(.system(size: 16, weight: .medium)).lineLimit(1).minimumScaleFactor(0.8)
                    }.frame(maxWidth: .infinity).frame(height: height).background(Color(white: 0.10), in: .capsule)
                }.accessibilityLabel(presentation.primary.title).accessibilityIdentifier("widget.\(presentation.layout.rawValue).\(presentation.primary.rawValue)")
                HStack(spacing: 8) {
                    ForEach(presentation.shortcuts, id: \.self) { destination in
                        Link(destination: destination.url) { WidgetGlyph(destination: destination).frame(width: height, height: height).background(Color(white: 0.10), in: .circle) }.accessibilityLabel(destination.title).accessibilityIdentifier("widget.\(presentation.layout.rawValue).\(destination.rawValue)")
                        if destination != presentation.shortcuts.last { Spacer(minLength: 0) }
                    }
                }
            }
        }.foregroundStyle(.white)
    }
}
public struct ClaudeWidgetView: View {
    public let presentation: ClaudeWidgetPresentation
    public init(presentation: ClaudeWidgetPresentation) { self.presentation = presentation }
    public var body: some View { ClaudeWidgetContent(presentation: presentation).containerBackground(for: .widget) { ClaudeWidgetBackground() }.widgetURL(presentation.primary.url) }
}
public struct ClaudeWidgetBackground: View {
    public init() {}
    public var body: some View { LinearGradient(colors: [Color(white: 0.20), Color(white: 0.12)], startPoint: .top, endPoint: .bottom) }
}
private struct WidgetGlyph: View {
    let destination: ClaudeWidgetDestination
    var body: some View {
        Group {
            switch destination {
            case .voice:
                HStack(spacing: 2.5) { ForEach(Array([7.0, 15.0, 21.0, 17.0, 8.0].enumerated()), id: \.offset) { _, height in Capsule().frame(width: 1.7, height: height) } }.frame(width: 25, height: 25)
            case .dispatch:
                ZStack(alignment: .top) { RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1.8).frame(width: 15, height: 20).offset(y: 3); RoundedRectangle(cornerRadius: 2).stroke(lineWidth: 1.5).frame(width: 8, height: 7).offset(y: 9); Path { path in path.move(to: CGPoint(x: 8, y: 0)); path.addLine(to: CGPoint(x: 8, y: 5)); path.move(to: CGPoint(x: 13, y: 2)); path.addLine(to: CGPoint(x: 13, y: 5)) }.stroke(style: StrokeStyle(lineWidth: 1.8, lineCap: .round)).frame(width: 22, height: 25) }.frame(width: 25, height: 25)
            default: Image(systemName: destination == .camera ? "camera" : destination == .code ? "chevron.left.forwardslash.chevron.right" : destination == .newCodeSession ? "plus" : "magnifyingglass").resizable().scaledToFit().fontWeight(.light).frame(width: 22, height: 22)
            }
        }
    }
}
#endif
