import Foundation

/// Allocates measured cell widths. Short tables fill the viewport; wide tables scroll.
/// The width cap is a host presentation choice, not a claim about uncaptured Claude tables.
public enum MarkdownTableMetrics {
    public static func columnWidths(idealWidths: [Double], availableWidth: Double, maximumColumnWidth: Double = 174)
        -> [Double]
    {
        guard !idealWidths.isEmpty else { return [] }
        let cap = maximumColumnWidth.isFinite ? max(24, maximumColumnWidth) : 174
        let widths = idealWidths.map { $0.isFinite ? min(cap, max(24, $0)) : cap }
        guard availableWidth.isFinite, availableWidth > 0 else { return widths }
        let equal = availableWidth / Double(widths.count)
        if widths.allSatisfy({ $0 <= equal }) { return Array(repeating: equal, count: widths.count) }
        let extra = max(0, availableWidth - widths.reduce(0, +)) / Double(widths.count)
        return widths.map { $0 + extra }
    }
}

#if canImport(UIKit)
    import SwiftUI

    struct ClaudeMarkdownTableLayout: Layout {
        var columns: Int
        var availableWidth: CGFloat
        var maximumColumnWidth: CGFloat
        private func measurements(_ subviews: Subviews) -> (widths: [CGFloat], heights: [CGFloat]) {
            guard columns > 0 else { return ([], []) }
            var ideals = Array(repeating: 0.0, count: columns)
            for index in subviews.indices {
                ideals[index % columns] = max(ideals[index % columns], subviews[index].sizeThatFits(.unspecified).width)
            }
            let widths = MarkdownTableMetrics.columnWidths(
                idealWidths: ideals, availableWidth: availableWidth, maximumColumnWidth: maximumColumnWidth)
            var heights = Array(repeating: 0.0, count: (subviews.count + columns - 1) / columns)
            for index in subviews.indices {
                heights[index / columns] = max(
                    heights[index / columns],
                    subviews[index].sizeThatFits(.init(width: widths[index % columns], height: nil)).height)
            }
            return (widths.map { CGFloat($0) }, heights.map { CGFloat($0) })
        }
        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
            let metrics = measurements(subviews)
            return CGSize(width: metrics.widths.reduce(0, +), height: metrics.heights.reduce(0, +))
        }
        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
            guard columns > 0 else { return }
            let metrics = measurements(subviews)
            var x = bounds.minX, y = bounds.minY
            for index in subviews.indices {
                let column = index % columns, row = index / columns
                if column == 0 {
                    x = bounds.minX
                    if row > 0 { y += metrics.heights[row - 1] }
                }
                subviews[index].place(
                    at: CGPoint(x: x, y: y), anchor: .topLeading,
                    proposal: .init(width: metrics.widths[column], height: metrics.heights[row]))
                x += metrics.widths[column]
            }
        }
    }
#endif
