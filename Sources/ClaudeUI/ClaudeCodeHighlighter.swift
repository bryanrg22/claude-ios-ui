import Foundation
import Highlighter

public enum ClaudeCodeSyntaxTheme: String, Sendable { case dark = "atom-one-dark", light = "atom-one-light" }

/// Offline syntax coloring. Source is data passed to bundled highlight.js, never executed.
/// Main-actor isolation keeps each JavaScriptCore context on its owning UI thread.
@MainActor public final class ClaudeCodeHighlighter {
    public static let shared = ClaudeCodeHighlighter()
    public static let maximumHighlightedUTF16Length = 100_000
    private var engines: [ClaudeCodeSyntaxTheme: Highlighter] = [:]
    private let cache = NSCache<NSString, NSAttributedString>()
    public init() {
        cache.countLimit = 64
        cache.totalCostLimit = 2_000_000
    }
    public func highlight(_ source: String, language: String?, theme: ClaudeCodeSyntaxTheme) -> NSAttributedString {
        let plain = NSAttributedString(string: source)
        guard !source.isEmpty, source.utf16.count <= Self.maximumHighlightedUTF16Length,
            let name = language?.split(whereSeparator: { $0.isWhitespace }).first?.lowercased(), !name.isEmpty
        else { return plain }
        let aliases = [
            "py": "python", "js": "javascript", "ts": "typescript", "sh": "bash", "rb": "ruby", "rs": "rust",
            "c++": "cpp", "c#": "csharp", "html": "xml"
        ]
        let canonical = aliases[name] ?? name
        let key = (theme.rawValue + "\u{0}" + canonical + "\u{0}" + source) as NSString
        if let value = cache.object(forKey: key) { return value }
        let engine: Highlighter
        if let existing = engines[theme] {
            engine = existing
        } else {
            guard let created = Highlighter(), created.setTheme(theme.rawValue) else { return plain }
            engines[theme] = created
            engine = created
        }
        guard engine.supportedLanguages().contains(canonical), let colored = engine.highlight(source, as: canonical),
            colored.string == source
        else { return plain }
        // Keep only token foreground colors. SwiftUI owns font, spacing, selection and card background.
        let result = NSMutableAttributedString(string: source)
        colored.enumerateAttributes(in: NSRange(location: 0, length: colored.length)) { attributes, range, _ in
            if let color = attributes[.foregroundColor] {
                result.addAttribute(.foregroundColor, value: color, range: range)
            }
        }
        let immutable = NSAttributedString(attributedString: result)
        cache.setObject(immutable, forKey: key, cost: source.utf16.count * 2)
        return immutable
    }
}
