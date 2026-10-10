import XCTest

/// Helpers shared by every UI test case.
extension XCTestCase {
    @MainActor func capture(_ name: String) {
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}

extension XCUIElement {
    /// Types `text` and checks that the field received every character, retrying up to three times.
    ///
    /// The simulator's synthesized keyboard occasionally drops a keystroke: measured on iOS 27, a doubled letter in
    /// the first word ("Keep" became "Kep") was lost in about 1 of 10 attempts, in two differently built text fields.
    /// A field that genuinely loses input still fails after the retries.
    /// Some text views report their value a moment after typing, so each check waits up to 2 seconds for the value
    /// to catch up before treating a keystroke as dropped.
    @MainActor func typeTextVerified(_ text: String, file: StaticString = #filePath, line: UInt = #line) {
        let initial = currentText
        let expected = initial + text
        for _ in 1...3 {
            typeText(text)
            if waitForText(expected) { return }
            let added = currentText.count - initial.count
            if added > 0 { typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: added)) }
        }
        XCTFail(
            "Field did not receive \"\(text)\" after 3 attempts; it contains \"\(currentText)\"", file: file, line: line
        )
    }

    @MainActor private func waitForText(_ expected: String) -> Bool {
        let deadline = Date().addingTimeInterval(2)
        while Date() < deadline {
            if currentText == expected { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return currentText == expected
    }

    /// The field's text, treating a shown placeholder as empty.
    @MainActor private var currentText: String {
        let text = value as? String ?? ""
        return text == placeholderValue ? "" : text
    }
}

extension XCUIElement {
    /// Taps a text field and waits until it has keyboard focus, so the typing that follows is not sent too early.
    ///
    /// `typeText` fails with "Neither element nor any descendant has keyboard focus" when it runs before the tap has
    /// taken effect, which happens intermittently on slower machines such as CI runners. If focus does not arrive the
    /// tap is repeated; after that the helper returns anyway and leaves the verdict to `typeText`, so it never fails
    /// a test that would have passed without it.
    @MainActor func tapToFocus(timeout: TimeInterval = 3) {
        for _ in 1...3 {
            tap()
            let deadline = Date().addingTimeInterval(timeout)
            while Date() < deadline {
                if ownsKeyboardFocus { return }
                RunLoop.current.run(until: Date().addingTimeInterval(0.1))
            }
        }
    }

    /// Whether this element, or a text input inside it, has keyboard focus.
    @MainActor private var ownsKeyboardFocus: Bool {
        func focused(_ element: XCUIElement) -> Bool {
            element.exists && (element.value(forKey: "hasKeyboardFocus") as? Bool) == true
        }
        if focused(self) { return true }
        let inputs = [
            descendants(matching: .textField), descendants(matching: .textView), descendants(matching: .searchField)
        ]
        return inputs.contains { query in focused(query.firstMatch) }
    }
}

extension XCUIElement {
    /// Taps once the element has stopped moving.
    ///
    /// A menu or sheet that is still animating in reports its frame of that instant, so a tap sent straight after
    /// the tap that opened it is aimed at a position the element then moves away from. Measured on CI: a menu row
    /// whose settled frame spans y 502-546 was tapped at y 547.5 and the tap was lost. This waits until two readings
    /// of the frame, 0.1 seconds apart, agree and the element is hittable, then taps. If that never happens within
    /// `timeout` it taps anyway, so it never fails a test that would have passed without it.
    @MainActor func tapWhenSettled(timeout: TimeInterval = 3) {
        let deadline = Date().addingTimeInterval(timeout)
        var previous = CGRect.null
        while Date() < deadline {
            let current = exists ? frame : .null
            if !current.isEmpty, current == previous, isHittable { break }
            previous = current
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        tap()
    }
}
