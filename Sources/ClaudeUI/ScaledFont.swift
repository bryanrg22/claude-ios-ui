#if canImport(UIKit)
    import SwiftUI

    /// Applies a system font that is exactly `size` points at the default text size and follows the user's
    /// Dynamic Type setting from there, scaling the way `style` does.
    ///
    /// The size goes through `@ScaledMetric`, so it updates live when the setting changes and is what Apple's
    /// accessibility audit recognises as supporting Dynamic Type. (Wrapping a `UIFontMetrics`-scaled `UIFont` in
    /// `Font` scales at launch but is still reported as unsupported.) The default-size result is unchanged, so
    /// existing screenshot references keep matching.
    ///
    /// Pass whole-point sizes. Scaling is relative to the text style's whole-point default, so a fractional size
    /// such as 13.3 comes back as 13.333 and shifts line height by a hair, enough to reflow a screenshot.
    struct ScaledSystemFont: ViewModifier {
        @ScaledMetric private var size: CGFloat
        private let weight: Font.Weight
        private let design: Font.Design

        init(size: CGFloat, weight: Font.Weight, design: Font.Design, relativeTo style: Font.TextStyle) {
            _size = ScaledMetric(wrappedValue: size, relativeTo: style)
            self.weight = weight
            self.design = design
        }

        func body(content: Content) -> some View {
            content.font(.system(size: size, weight: weight, design: design))
        }
    }

    extension View {
        /// Use instead of `.font(.system(size:))` for text that should follow the system text-size setting.
        func scaledFont(
            _ size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default,
            relativeTo style: Font.TextStyle = .body
        ) -> some View {
            modifier(ScaledSystemFont(size: size, weight: weight, design: design, relativeTo: style))
        }
    }
#endif
