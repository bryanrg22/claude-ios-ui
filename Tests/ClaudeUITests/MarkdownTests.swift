import Foundation
import Testing
@testable import ClaudeUI

@Test func markdownParsesHeadingsRulesAndNestedInlineSemantics() {
    let doc = MarkdownDocumentModel(source: "## A **bold and *italic*** title\n\n---\n\nText with `code` and ~~old~~.")
    #expect(doc.blocks == [.heading(level: 2, content: [.text("A "), .strong([.text("bold and "), .emphasis([.text("italic")])]), .text(" title")]), .rule, .paragraph([.text("Text with "), .code("code"), .text(" and "), .strikethrough([.text("old")]), .text(".")])])
}
@Test func markdownPreservesOrderedStartNestedListAndTaskState() {
    let doc = MarkdownDocumentModel(source: "3. Third\n   - Nested\n4. Fourth\n\n- [x] Done\n- [ ] Pending")
    guard case .list(let start, let items) = doc.blocks[0] else { Issue.record("Expected ordered list"); return }
    #expect(start == 3); #expect(items.count == 2)
    #expect(items[0].blocks == [.paragraph([.text("Third")]), .list(start: nil, items: [.init(blocks: [.paragraph([.text("Nested")])])])])
    guard case .list(_, let tasks) = doc.blocks[1] else { Issue.record("Expected task list"); return }
    #expect(tasks.map(\.checked) == [true, false])
}
@Test func markdownQuotesRetainMultipleParagraphsAndLists() {
    let doc = MarkdownDocumentModel(source: "> One\n>\n> Two\n>\n> - Item")
    #expect(doc.blocks == [.quote([.paragraph([.text("One")]), .paragraph([.text("Two")]), .list(start: nil, items: [.init(blocks: [.paragraph([.text("Item")])])])])])
}
@Test func markdownCodePreservesWhitespaceAndDoesNotParseMarkup() {
    let source = "```swift\n  let value = \"**literal**\"\n\n```"
    #expect(MarkdownDocumentModel(source: source).blocks == [.code(language: "swift", content: "  let value = \"**literal**\"\n\n")])
    #expect(MarkdownDocumentModel(source: "```python\nprint('streaming')").blocks == [.code(language: "python", content: "print('streaming')\n")])
}
@Test func markdownTableAlignmentsEscapesAndMissingCells() {
    let doc = MarkdownDocumentModel(source: "| Name | Count | Note |\n| :--- | ---: | :---: |\n| A\\|B | 2 | **bold** |\n| C | 3 |")
    guard case .table(let header, let rows, let alignments) = doc.blocks.first else { Issue.record("Expected GFM table"); return }
    #expect(header.count == 3); #expect(rows.count == 2); #expect(alignments == [.left, .right, .center])
    #expect(rows[0][0] == [.text("A|B")]); #expect(rows[0][2] == [.strong([.text("bold")])]); #expect(rows[1][2].isEmpty)
}
@Test func markdownLinksImagesAndLineBreaksRemainValueData() {
    let source = "[Guide](https://example.com/guide) ![A **garden**](https://example.com/image.png \"Caption\")\nsoft  \nhard"
    let doc = MarkdownDocumentModel(source: source)
    guard case .paragraph(let parts) = doc.blocks[0] else { Issue.record("Expected paragraph"); return }
    #expect(parts.contains(.link(destination: "https://example.com/guide", children: [.text("Guide")])))
    #expect(parts.contains(.image(.init(source: "https://example.com/image.png", title: "Caption", alt: "A garden"))))
    #expect(parts.contains(.softBreak)); #expect(parts.contains(.hardBreak))
    #expect(doc.source == source)
}
@Test func markdownHTMLIsLiteralAndUnsupportedExtensionsAreExplicit() {
    #expect(MarkdownDocumentModel(source: "<script>alert('hello')</script>").blocks == [.unsupported(kind: .html, source: "<script>alert('hello')</script>\n")])
    let literal = MarkdownDocumentModel(source: "$x^2$ and \\(y\\)")
    guard case .paragraph(let content) = literal.blocks[0] else { Issue.record("Expected literal math paragraph"); return }
    #expect(content.map(\.plainText).joined().contains("$x^2$"))
    let custom = MarkdownDocumentModel(source: "$$x$$", blocks: [.unsupported(kind: .math, source: "x")])
    #expect(custom.blocks == [.unsupported(kind: .math, source: "x")])
}
@Test func markdownActionURLsRoundTripSpecialCharactersWithoutRequests() {
    let image = MarkdownAction.image(.init(source: "https://example.com/a?b=x&c=y#z", title: "Title &?", alt: "園 🌱"))
    #expect(MarkdownAction.decodePresentationURL(image.presentationURL!) == image)
    let math = MarkdownAction.unsupported(kind: .math, source: "x + y / z & a")
    #expect(MarkdownAction.decodePresentationURL(math.presentationURL!) == math)
    #expect(MarkdownAction.decodePresentationURL(URL(string: "https://example.com")!) == nil)
}
@Test func markdownEmptyAndEscapedMarkersRemainLiteral() {
    #expect(MarkdownDocumentModel(source: " \n ").blocks.isEmpty)
    #expect(MarkdownDocumentModel(source: "\\*not emphasis\\* and -- literal").blocks == [.paragraph([.text("*not emphasis* and -- literal")])])
}
