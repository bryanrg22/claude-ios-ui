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
