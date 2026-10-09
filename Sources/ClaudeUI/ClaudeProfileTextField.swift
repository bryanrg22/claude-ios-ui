#if canImport(UIKit)
    import SwiftUI
    import UIKit

    /// Keeps UIKit's active edit buffer authoritative while the host receives draft changes.
    /// Reassigning a stale SwiftUI value during an input event can replace characters in flight.
    struct ClaudeProfileTextField: UIViewRepresentable {
        let text: String
        let placeholder: String
        let identifier: String
        let update: (String) -> Void
        var isURL: Bool = false
        func makeCoordinator() -> Coordinator { Coordinator(update: update) }
        func makeUIView(context: Context) -> UITextField {
            let field = UITextField()
            field.text = text
            field.placeholder = placeholder
            field.font = .systemFont(ofSize: 17)
            field.textColor = .label
            field.autocorrectionType = .no
            field.spellCheckingType = .no
            field.textContentType = isURL ? .URL : .name
            field.keyboardType = isURL ? .URL : .default
            if isURL { field.autocapitalizationType = .none }
            field.accessibilityIdentifier = identifier
            field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            field.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .editingChanged)
            return field
        }
        func updateUIView(_ field: UITextField, context: Context) {
            context.coordinator.update = update
            if !field.isFirstResponder, field.text != text { field.text = text }
        }
        final class Coordinator: NSObject {
            var update: (String) -> Void
            init(update: @escaping (String) -> Void) { self.update = update }
            @objc func changed(_ field: UITextField) { update(field.text ?? "") }
        }
    }
#endif
