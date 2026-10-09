import Testing
@testable import ClaudeUI

struct MarkdownTableTests {
    @Test func shortColumnsFitWithoutHorizontalScroll() {
        let widths = MarkdownTableMetrics.columnWidths(idealWidths: [75, 80, 86], availableWidth: 361)
        #expect(widths.count == 3)
        #expect(abs(widths.reduce(0, +) - 361) < 0.001)
        #expect(widths[0] == widths[2])
    }
    @Test func UnequalColumnsKeepMeasuredContentAndDistributeSpace() {
        let widths = MarkdownTableMetrics.columnWidths(idealWidths: [150, 40, 80], availableWidth: 300)
        #expect(widths == [160, 50, 90])
    }
    @Test func wideTablesScrollAndLongCellsWrapAtTheHostCap() {
        let widths = MarkdownTableMetrics.columnWidths(idealWidths: [900, 120, 130, 140], availableWidth: 361)
        #expect(widths == [174, 120, 130, 140])
        #expect(widths.reduce(0, +) > 361)
    }
    @Test func invalidGeometryStaysFiniteAndEmptyTableStaysEmpty() {
        #expect(MarkdownTableMetrics.columnWidths(idealWidths: [], availableWidth: 300).isEmpty)
        let widths = MarkdownTableMetrics.columnWidths(
            idealWidths: [.nan, .infinity, -1], availableWidth: .nan, maximumColumnWidth: .infinity)
        #expect(widths == [174, 174, 24])
    }
    @Test func nestedCodeDetectionPreservesPlainTextAndLinks() {
        let nested: MarkdownInline = .link(destination: "https://example.com", children: [.strong([.code("a_b")])])
        #expect(nested.containsInlineCode)
        #expect(nested.plainText == "a_b")
        #expect(!MarkdownInline.strong([.text("plain")]).containsInlineCode)
    }
}
