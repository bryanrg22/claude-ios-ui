import Foundation
import Testing
@testable import ClaudeUI
#if canImport(UIKit)
import UIKit
private typealias PlatformColor = UIColor
#else
import AppKit
private typealias PlatformColor = NSColor
#endif

@MainActor @Test func pythonSyntaxUsesReferenceConsistentTokenPalette() {
    let text = "def greet(name: str) -> str:\n    return f\"Hello, {name}!\"\n"
    let output = ClaudeCodeHighlighter().highlight(text, language: "python", theme: .dark)
    #expect(output.string == text)
    func color(_ token: String) -> PlatformColor? { output.attribute(.foregroundColor, at: (text as NSString).range(of: token).location, effectiveRange: nil) as? PlatformColor }
    #expect(color("def") != nil); #expect(color("def") != color("greet")); #expect(color("Hello") != color("return")); #expect(color("str") != color("greet"))
    #expect(output.attribute(.font, at: 0, effectiveRange: nil) == nil)
    #expect(output.attribute(.backgroundColor, at: 0, effectiveRange: nil) == nil)
}
@MainActor @Test func syntaxPreservesUnicodeWhitespaceAndLiteralHTML() {
    let renderer = ClaudeCodeHighlighter()
    for source in ["\tlet café = \"🌿 & <script>throw 1</script>\"\r\n\n", "/* **not markdown** */\nlet quote = \"\\\"; throw Error()\"\n", "// 👨‍👩‍👧‍👦 é\nlet x = 2\n"] {
        let output = renderer.highlight(source, language: "swift", theme: .dark)
        #expect(output.string == source); #expect(output.length == (source as NSString).length)
    }
}
@MainActor @Test func syntaxUnknownMissingAndOversizedInputFallsBackExactly() {
    let renderer = ClaudeCodeHighlighter()
    for language: String? in [nil, "", "not-a-language", "plaintext"] {
        let output = renderer.highlight("<>&\n  literal", language: language, theme: .dark)
        #expect(output.string == "<>&\n  literal")
        if language != "plaintext" { #expect(output.attributes(at: 0, effectiveRange: nil).isEmpty) }
    }
    let huge = String(repeating: "x", count: ClaudeCodeHighlighter.maximumHighlightedUTF16Length + 1)
    let output = renderer.highlight(huge, language: "python", theme: .dark)
    #expect(output.string == huge); #expect(output.attributes(at: 0, effectiveRange: nil).isEmpty)
    #expect(renderer.highlight("", language: "python", theme: .dark).length == 0)
}
@MainActor @Test func syntaxAliasAndThemeCacheDoNotLeakColors() {
    let renderer = ClaudeCodeHighlighter(); let source = "def greeting():\n    return 'hello'\n"
    let dark = renderer.highlight(source, language: "python", theme: .dark)
    #expect(renderer.highlight(source, language: "PY extra-info", theme: .dark).isEqual(to: dark))
    let light = renderer.highlight(source, language: "python", theme: .light)
    #expect(light.string == dark.string)
    #expect((dark.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? PlatformColor) != (light.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? PlatformColor))
    #expect(renderer.highlight(source, language: "python", theme: .dark).isEqual(to: dark))
}
@MainActor @Test func syntaxIncompleteStreamingFenceRemainsSourceExact() {
    let renderer = ClaudeCodeHighlighter()
    for source in ["def", "def greet(", "def greet(name):\n    return f\"Hello, {", "def greet(name):\n    return f\"Hello, {name}!\"\n"] {
        #expect(renderer.highlight(source, language: "python", theme: .dark).string == source)
    }
}
