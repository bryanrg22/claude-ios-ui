#if canImport(UIKit)
import SwiftUI
import UIKit

/// TextKit 1 draws the code decoration behind glyphs while UITextView retains native selection.
/// No padding characters are inserted, so copying preserves the parsed source text.
struct ClaudeSelectableInlineCode: UIViewRepresentable {
    let content: [MarkdownInline]
    let font: Font
    let theme: ClaudeMarkdownTheme
    var alignment: NSTextAlignment = .left
    let onAction: (MarkdownAction) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onAction: onAction) }
    func makeUIView(context: Context) -> UITextView {
        let storage = NSTextStorage()
        let layout = InlineCodeLayoutManager()
        let container = NSTextContainer(size: .zero)
        container.lineFragmentPadding = 0
        layout.addTextContainer(container); storage.addLayoutManager(layout)
        let view = UITextView(frame: .zero, textContainer: container)
        view.backgroundColor = .clear; view.isEditable = false; view.isSelectable = true
        view.isScrollEnabled = false; view.textContainerInset = .zero
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.delegate = context.coordinator
        view.accessibilityIdentifier = "markdown.inlineCode"
        return view
    }
    func updateUIView(_ view: UITextView, context: Context) {
        context.coordinator.onAction = onAction
        let value = attributed(content, context: context)
        // Avoid replacing the storage during a selection or an unrelated parent rerender.
        if !view.attributedText.isEqual(to: value) { view.attributedText = value }
        view.linkTextAttributes = [.foregroundColor: UIColor(theme.link), .underlineStyle: NSUnderlineStyle.single.rawValue]
    }
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        guard let width = proposal.width, width > 0, width.isFinite else {
            let rect = uiView.attributedText.boundingRect(with: CGSize(width: 100_000, height: 100_000), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
            return CGSize(width: ceil(rect.width), height: ceil(rect.height))
        }
        return CGSize(width: width, height: ceil(uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height))
    }
    private func attributed(_ children: [MarkdownInline], context: Context, bold: Bool = false, italic: Bool = false, strike: Bool = false) -> NSAttributedString {
        let result = NSMutableAttributedString(string: "")
        for child in children {
            let run: NSMutableAttributedString
            switch child {
            case .strong(let nested): run = NSMutableAttributedString(attributedString: attributed(nested, context: context, bold: true, italic: italic, strike: strike))
            case .emphasis(let nested): run = NSMutableAttributedString(attributedString: attributed(nested, context: context, bold: bold, italic: true, strike: strike))
            case .strikethrough(let nested): run = NSMutableAttributedString(attributedString: attributed(nested, context: context, bold: bold, italic: italic, strike: true))
            case .link(let destination, let nested):
                run = NSMutableAttributedString(attributedString: attributed(nested, context: context, bold: bold, italic: italic, strike: strike))
                if let url = URL(string: destination) { run.addAttribute(.link, value: url, range: NSRange(location: 0, length: run.length)) }
            default:
                var face = font
                var attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(theme.foreground)]
                if case .code = child { face = theme.codeFont; attributes[.foregroundColor] = UIColor(theme.inlineCodeForeground); attributes[.inlineCodeFill] = UIColor(theme.inlineCodeBackground) }
                if bold { face = face.bold() }; if italic { face = face.italic() }
                attributes[.font] = face.resolve(in: context.environment.fontResolutionContext).ctFont as UIFont
                if strike { attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue }
                var text = child.plainText
                if case .image(let image) = child { text = "▧ " + (image.alt.isEmpty ? "Image" : image.alt); attributes[.link] = MarkdownAction.image(image).presentationURL }
                if case .unsupported(let kind, let source) = child { attributes[.link] = MarkdownAction.unsupported(kind: kind, source: source).presentationURL }
                run = NSMutableAttributedString(string: text, attributes: attributes)
            }
            result.append(run)
        }
        let paragraph = NSMutableParagraphStyle(); paragraph.lineSpacing = theme.lineSpacing; paragraph.alignment = alignment
        result.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: result.length))
        return result
    }
    final class Coordinator: NSObject, UITextViewDelegate {
        var onAction: (MarkdownAction) -> Void
        init(onAction: @escaping (MarkdownAction) -> Void) { self.onAction = onAction }
        func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
            guard case .link(let url) = textItem.content else { return defaultAction }
            return UIAction { [weak self] _ in self?.onAction(MarkdownAction.decodePresentationURL(url) ?? .openLink(url)) }
        }
    }
}
private extension NSAttributedString.Key { static let inlineCodeFill = Self("ClaudeUI.InlineCodeFill") }
private final class InlineCodeLayoutManager: NSLayoutManager {
    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        guard let storage = textStorage else { return super.drawBackground(forGlyphRange: glyphsToShow, at: origin) }
        let characters = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        storage.enumerateAttribute(.inlineCodeFill, in: characters) { value, range, _ in
            guard let color = value as? UIColor else { return }
            let glyphs = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            self.enumerateLineFragments(forGlyphRange: glyphs) { _, _, container, lineRange, _ in
                let visible = NSIntersectionRange(glyphs, lineRange)
                guard visible.length > 0 else { return }
                var rect = self.boundingRect(forGlyphRange: visible, in: container).offsetBy(dx: origin.x, dy: origin.y)
                rect = rect.insetBy(dx: -1.5, dy: 0)
                // Keep rounded corners visible when code starts or ends at a wrapped line edge.
                let left = max(origin.x, rect.minX), right = min(origin.x + container.size.width, rect.maxX)
                rect.origin.x = left; rect.size.width = max(0, right - left)
                color.setFill(); UIBezierPath(roundedRect: rect, cornerRadius: 5).fill()
            }
        }
        // UIKit's own backgrounds and selection remain above the decorative code pill.
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
    }
}
#endif
