import XCTest

final class SessionUITests: XCTestCase {
    @MainActor func testDraftChangesVoiceToSendThenStreamingStopAndCompletion() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["composer.voice"].waitForExistence(timeout: 5))
        let draft = app.textFields["composer.draft"]
        draft.tapToFocus()
        draft.typeText("Hello")
        XCTAssertTrue(app.buttons["composer.send"].exists)
        app.buttons["composer.send"].tap()
        XCTAssertTrue(app.buttons["composer.stop"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["composer.voice"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.staticTexts["Claude is AI and can make mistakes."].exists)
    }
    @MainActor func testDictationCancelPreservesDraft() {
        let app = XCUIApplication()
        app.launchArguments = ["--typed"]
        app.launch()
        app.buttons["composer.dictate"].tap()
        XCTAssertTrue(app.buttons["dictation.cancel"].waitForExistence(timeout: 2))
        app.buttons["dictation.stop"].tap()
        XCTAssertTrue(app.buttons["composer.dictate"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["dictation.cancel"].exists)
        XCTAssertEqual(app.textFields["composer.draft"].value as? String, "Reply with a short greeting.")
        app.buttons["composer.dictate"].tap()
        app.buttons["dictation.cancel"].tapWhenSettled()
        XCTAssertEqual(app.textFields["composer.draft"].value as? String, "Reply with a short greeting.")
    }
    @MainActor func testModelSelectionChangesComposer() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["composer.model"].tap()
        capture("models-dark")
        app.buttons["model.Haiku 5.5"].tap()
        XCTAssertTrue(app.buttons["composer.model"].label.contains("Haiku 5.5"))
    }

    @MainActor func testAttachmentPermissionAndEffortDrillIns() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["composer.attach"].tap()
        XCTAssertTrue(app.staticTexts["Add to session"].waitForExistence(timeout: 3))
        capture("attachments-dark")
        app.buttons.containing(.staticText, identifier: "Permission").firstMatch.tap()
        app.buttons.containing(.staticText, identifier: "Automatically approve").firstMatch.tapWhenSettled()
        XCTAssertTrue(app.staticTexts["Automatic"].exists)
        app.buttons["Close"].tap()
        app.buttons["composer.model"].tapWhenSettled()
        app.buttons["model.effort"].tapWhenSettled()
        capture("effort-dark")
        app.buttons["effort.Low"].tap()
        app.buttons["Close"].tapWhenSettled()
        XCTAssertTrue(app.buttons["composer.model"].label.contains("Low"))
    }
    @MainActor func testFeedbackCancellationLeavesResponseUnrated() {
        let app = XCUIApplication()
        app.launchArguments = ["--complete"]
        app.launch()
        app.buttons["Good response"].tap()
        XCTAssertTrue(app.staticTexts["Feedback"].waitForExistence(timeout: 2))
        app.buttons["Close"].tap()
        app.buttons["Bad response"].tapWhenSettled()
        XCTAssertTrue(app.staticTexts["Type of issue"].waitForExistence(timeout: 2))
        app.buttons["Close"].tap()
        XCTAssertTrue(app.buttons["Good response"].exists)
    }

    @MainActor func testEditCancelRestoresAssistantAndUnsentDraft() {
        let app = XCUIApplication()
        app.launchArguments = ["--complete", "--typed"]
        app.launch()
        app.staticTexts["Reply with a short greeting."].firstMatch.press(forDuration: 1)
        app.buttons["Edit"].tap()
        XCTAssertTrue(app.buttons["editing.cancel"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["Hey Jordan! What's on your mind tonight?"].exists)
        capture("editing-message")
        app.buttons["editing.cancel"].tap()
        XCTAssertTrue(app.staticTexts["Hey Jordan! What's on your mind tonight?"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.textFields["composer.draft"].value as? String, "Reply with a short greeting.")
    }
}
