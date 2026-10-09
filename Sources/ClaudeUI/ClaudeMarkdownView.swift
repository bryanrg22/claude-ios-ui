#if canImport(UIKit)
import SwiftUI

/// Theme values are independent of the AST. Claude's uncaptured rich-block metrics remain provisional.
public struct ClaudeMarkdownTheme {
    public var bodyFont: Font
    public var headingFonts: [Font]
    public var codeFont: Font
    public var foreground: Color = .primary
    public var secondary: Color = .secondary
    public var link: Color = ClaudePalette.adaptive(light: 0.30, dark: 0.75)
    public var inlineCodeForeground: Color = Color(red: 0.40, green: 0.64, blue: 0.91)
    public var quoteBar: Color = .secondary.opacity(0.45)
    public var codeBackground: Color = ClaudePalette.adaptive(light: 1, dark: 0.125)
    public var inlineCodeBackground: Color = .secondary.opacity(0.10)
    public var tableHeaderBackground: Color = ClaudePalette.adaptive(light: 1, dark: 0.16)
    public var rule: Color = .secondary.opacity(0.25)
    public var blockSpacing: CGFloat = 18
    public var lineSpacing: CGFloat = 4
    public var listSpacing: CGFloat = 9
    public var tableColumnWidth: CGFloat = 150
    public init(serifName: String = "Newsreader16pt-Regular", bodySize: CGFloat = 20) {
        foreground = ClaudePalette.ink
        bodyFont = .custom(serifName, size: bodySize, relativeTo: .body)
        headingFonts = [28, 25, 22, 20, 19, 18].map { .custom(serifName, size: $0, relativeTo: .headline).bold() }
        codeFont = .system(size: 15, design: .monospaced)
    }
    public static var artifact: Self { var theme = Self(); theme.bodyFont = .system(size: 17); theme.lineSpacing = 6; return theme }
}

public struct ClaudeMarkdownView: View {
    public let document: MarkdownDocumentModel
    public var theme: ClaudeMarkdownTheme
    @State private var tableViewport: CGFloat = 0
    @State private var expandedCode: ExpandedCode?
    @Environment(\.colorScheme) private var colorScheme
    private let codeContent: ((String?, String) -> AttributedString)?
    private let onAction: (MarkdownAction) -> Void
    private let imageContent: ((MarkdownImage) -> AnyView)?
    private let unsupportedContent: ((MarkdownUnsupportedKind, String) -> AnyView)?
    public init(document: MarkdownDocumentModel, theme: ClaudeMarkdownTheme = .init(), imageContent: ((MarkdownImage) -> AnyView)? = nil, codeContent: ((String?, String) -> AttributedString)? = nil, unsupportedContent: ((MarkdownUnsupportedKind, String) -> AnyView)? = nil, onAction: @escaping (MarkdownAction) -> Void = { _ in }) {
        ClaudeFontResources.register()
        self.document = document; self.theme = theme; self.imageContent = imageContent; self.codeContent = codeContent; self.unsupportedContent = unsupportedContent; self.onAction = onAction
    }
    public init(_ source: String, theme: ClaudeMarkdownTheme = .init(), onAction: @escaping (MarkdownAction) -> Void = { _ in }) { self.init(document: .init(source: source), theme: theme, onAction: onAction) }
    public var body: some View {
        blocks(document.blocks).foregroundStyle(theme.foreground)
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { tableViewport = $0 }
            .sheet(item: $expandedCode) { item in
                VStack(spacing: 30) {
                    ZStack { Text(item.language.map { $0.prefix(1).uppercased() + $0.dropFirst() + " code" } ?? "Code").font(.system(size: 17, weight: .semibold)); HStack { Button { expandedCode = nil } label: { Image(systemName: "xmark").font(.system(size: 20)).frame(width: 44, height: 44) }.glassEffect(in: .circle).accessibilityLabel("Close code").accessibilityIdentifier("markdown.code.close"); Spacer() } }
                    ScrollView([.vertical, .horizontal]) { codeText(language: item.language, content: item.content).accessibilityIdentifier("markdown.code.expandedContent") }.defaultScrollAnchor(.topLeading, for: .alignment).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }.padding(16).background(ClaudePalette.background).presentationDetents([.large]).presentationCornerRadius(40).presentationDragIndicator(.hidden)
            }
            .environment(\.openURL, OpenURLAction { url in
                if let local = MarkdownAction.decodePresentationURL(url) { onAction(local) } else { onAction(.openLink(url)) }
                return .handled
            })
    }
    private func blocks(_ blocks: [MarkdownBlock]) -> some View {
        VStack(alignment: .leading, spacing: theme.blockSpacing) { ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in render(block) } }.frame(maxWidth: .infinity, alignment: .leading)
    }
    @ViewBuilder private func inline(_ content: [MarkdownInline], font: Font? = nil, alignment: MarkdownColumnAlignment = .left) -> some View {
        if content.contains(where: \.containsInlineCode) {
            ClaudeSelectableInlineCode(content: content, font: font ?? theme.bodyFont, theme: theme, alignment: alignment == .right ? .right : alignment == .center ? .center : .left, onAction: onAction)
        } else {
            inlineText(content, font: font ?? theme.bodyFont).lineSpacing(theme.lineSpacing).textSelection(.enabled).fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: alignment == .right ? .trailing : alignment == .center ? .center : .leading)
        }
    }
    private func render(_ block: MarkdownBlock) -> AnyView {
        switch block {
        case .paragraph(let content):
            if content.count == 1, case .image(let image) = content[0], let imageContent { return imageContent(image) }
            return AnyView(inline(content))
        case .heading(let level, let content): return AnyView(inline(content, font: (theme.headingFonts.isEmpty ? theme.bodyFont.bold() : theme.headingFonts[min(max(level - 1, 0), theme.headingFonts.count - 1)])).accessibilityAddTraits(.isHeader))
        case .rule: return AnyView(Rectangle().fill(theme.rule).frame(height: 1).accessibilityLabel("Horizontal rule"))
        case .quote(let children): return AnyView(HStack(alignment: .top, spacing: 14) { blocks(children) }.padding(.leading, 17).overlay(alignment: .leading) { Rectangle().fill(theme.quoteBar).frame(width: 3) }.accessibilityIdentifier("markdown.quote"))
        case .list(let start, let items):
            return AnyView(VStack(alignment: .leading, spacing: theme.listSpacing) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(item.checked.map { $0 ? "☑" : "☐" } ?? start.map { "\($0 + index)." } ?? "•").font(theme.bodyFont).frame(minWidth: 18, alignment: .trailing)
                        blocks(item.blocks)
                    }
                }
            }.accessibilityIdentifier("markdown.list"))
        case .code(let language, let content):
            return AnyView(VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(language ?? "").font(.system(size: 14, design: .monospaced)).foregroundStyle(theme.secondary); Spacer()
                    Button { onAction(.copyCode(content)) } label: { Image(systemName: "square.on.square").frame(width: 28, height: 28) }.accessibilityLabel("Copy code").accessibilityIdentifier("markdown.code.copy")
                    Button { expandedCode = .init(language: language, content: content); onAction(.expandCode(language: language, content: content)) } label: { Image(systemName: "arrow.up.left.and.arrow.down.right").frame(width: 28, height: 28) }.accessibilityLabel("Expand code").accessibilityIdentifier("markdown.code.expand")
                }.foregroundStyle(theme.secondary).padding(.horizontal, 16).padding(.vertical, 8)
                Rectangle().fill(theme.rule).frame(height: 0.5)
                ScrollView(.horizontal) { codeText(language: language, content: content).accessibilityIdentifier("markdown.code.content") }.scrollIndicators(.hidden).padding(16)
            }.background(theme.codeBackground, in: .rect(cornerRadius: 24)).overlay { RoundedRectangle(cornerRadius: 24).stroke(theme.rule, lineWidth: 0.6) })
        case .table(let header, let rows, let alignments):
            let allRows = [header] + rows
            let columns = max(header.count, rows.map(\.count).max() ?? 0)
            return AnyView(ScrollView(.horizontal) {
                ClaudeMarkdownTableLayout(columns: columns, availableWidth: tableViewport, maximumColumnWidth: max(50, theme.tableColumnWidth) + 24) {
                    ForEach(allRows.indices, id: \.self) { row in
                        ForEach(0..<columns, id: \.self) { column in
                            let cell = column < allRows[row].count ? allRows[row][column] : []
                            let alignment = column < alignments.count ? alignments[column] : .left
                            inline(cell, font: row == 0 ? theme.bodyFont.bold() : theme.bodyFont, alignment: alignment)
                                .padding(.horizontal, 12).padding(.vertical, 10)
                                .frame(maxHeight: .infinity, alignment: .top)
                                .background(row == 0 ? theme.tableHeaderBackground : .clear)
                                .overlay(alignment: .bottom) { if row < allRows.count - 1 { Rectangle().fill(theme.rule).frame(height: 0.5) } }
                        }
                    }
                }.clipShape(.rect(cornerRadius: 8)).overlay { RoundedRectangle(cornerRadius: 8).stroke(theme.rule, lineWidth: 0.6) }
            }.accessibilityIdentifier("markdown.table"))
        case .unsupported(let kind, let source):
            if let unsupportedContent { return unsupportedContent(kind, source) }
            return AnyView(Text(verbatim: source).font(theme.codeFont).textSelection(.enabled).contextMenu { Button("Open content") { onAction(.unsupported(kind: kind, source: source)) } })
        }
    }
    private func codeText(language: String?, content: String) -> some View {
        Text(codeContent?(language, content) ?? defaultHighlightedCode(language: language, content: content)).font(theme.codeFont).textSelection(.enabled).fixedSize(horizontal: true, vertical: false)
    }
    private func defaultHighlightedCode(language: String?, content: String) -> AttributedString {
        let colored = ClaudeCodeHighlighter.shared.highlight(content, language: language, theme: colorScheme == .dark ? .dark : .light)
        return (try? AttributedString(colored, including: \.uiKit)) ?? AttributedString(content)
    }
    private func inlineText(_ children: [MarkdownInline], font: Font, bold: Bool = false, italic: Bool = false, strike: Bool = false, link: URL? = nil) -> Text {
        children.reduce(Text("")) { result, child in
            let piece: Text
            switch child {
            case .strong(let nested): piece = inlineText(nested, font: font, bold: true, italic: italic, strike: strike, link: link)
            case .emphasis(let nested): piece = inlineText(nested, font: font, bold: bold, italic: true, strike: strike, link: link)
            case .strikethrough(let nested): piece = inlineText(nested, font: font, bold: bold, italic: italic, strike: true, link: link)
            case .link(let destination, let nested): piece = inlineText(nested, font: font, bold: bold, italic: italic, strike: strike, link: URL(string: destination))
            default:
                var value = attributed([child], font: font, bold: bold, italic: italic, strike: strike)
                if let link { value.link = link; value.foregroundColor = theme.link; value.underlineStyle = .single }
                if case .code = child { piece = Text(value).customAttribute(InlineCodeAttribute()) } else { piece = Text(value) }
            }
            return Text("\(result)\(piece)")
        }
    }
    private func attributed(_ children: [MarkdownInline], font: Font, bold: Bool = false, italic: Bool = false, strike: Bool = false) -> AttributedString {
        var result = AttributedString()
        for child in children {
            var run = AttributedString()
            switch child {
            case .strong(let children): run = attributed(children, font: font, bold: true, italic: italic, strike: strike)
            case .emphasis(let children): run = attributed(children, font: font, bold: bold, italic: true, strike: strike)
            case .strikethrough(let children): run = attributed(children, font: font, bold: bold, italic: italic, strike: true)
            case .link(let destination, let children): run = attributed(children, font: font, bold: bold, italic: italic, strike: strike); run.link = URL(string: destination); run.foregroundColor = theme.link; run.underlineStyle = .single
            default:
                let value: String
                switch child {
                case .image(let image): value = "▧ " + (image.alt.isEmpty ? "Image" : image.alt)
                default: value = child.plainText
                }
                run = AttributedString(value)
                var face = font
                if case .code = child { face = theme.codeFont; run.foregroundColor = theme.inlineCodeForeground; run.backgroundColor = theme.inlineCodeBackground }
                if bold { face = face.bold() }; if italic { face = face.italic() }
                run.font = face; run.strikethroughStyle = strike ? .single : nil
                if case .image(let image) = child { run.link = MarkdownAction.image(image).presentationURL; run.foregroundColor = theme.link }
                if case .unsupported(let kind, let source) = child { run.link = MarkdownAction.unsupported(kind: kind, source: source).presentationURL }
            }
            result.append(run)
        }
        return result
    }
}
private struct ExpandedCode: Identifiable { let id = UUID(); let language: String?; let content: String }
private struct InlineCodeAttribute: TextAttribute {}
private struct InlineCodeRenderer: TextRenderer {
    var background: Color
    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for line in layout { for run in line {
            if run[InlineCodeAttribute.self] != nil { context.fill(Path(roundedRect: run.typographicBounds.rect.insetBy(dx: -3, dy: -1), cornerRadius: 6), with: .color(background)) }
            context.draw(run)
        } }
    }
}
#endif
