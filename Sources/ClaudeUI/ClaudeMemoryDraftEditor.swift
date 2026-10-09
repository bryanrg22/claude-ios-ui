#if canImport(UIKit)
    import SwiftUI
    import UIKit

    /// Preserve the native active edit buffer while forwarding draft changes to a host reducer.
    struct ClaudeMemoryDraftEditor: UIViewRepresentable {
        let text: String
        let placeholder: String
        let update: (String) -> Void
        func makeCoordinator() -> Coordinator { Coordinator(update: update) }
        func makeUIView(context: Context) -> UITextView {
            let view = UITextView()
            view.text = text
            view.font = .systemFont(ofSize: 17)
            view.textColor = .label
            view.backgroundColor = .clear
            view.textContainerInset = .zero
            view.textContainer.lineFragmentPadding = 0
            view.isScrollEnabled = false
            view.delegate = context.coordinator
            view.accessibilityIdentifier = "settings.memory.draft"
            view.accessibilityLabel = placeholder
            view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            return view
        }
        func updateUIView(_ view: UITextView, context: Context) {
            context.coordinator.update = update
            view.accessibilityLabel = placeholder
            if !view.isFirstResponder, view.text != text { view.text = text }
        }
        func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
            guard let width = proposal.width else { return nil }
            let natural = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height
            let height = min(104, max(22, natural))
            uiView.isScrollEnabled = natural > 104
            return CGSize(width: width, height: height)
        }
        final class Coordinator: NSObject, UITextViewDelegate {
            var update: (String) -> Void
            init(update: @escaping (String) -> Void) { self.update = update }
            func textViewDidChange(_ textView: UITextView) {
                update(textView.text)
                textView.invalidateIntrinsicContentSize()
            }
        }
    }
#endif
