import XCTest

final class VoiceUITests: XCTestCase {

    @MainActor func testInlineVoiceSettingsModelAndExitRestoreConversation() {
        let app = XCUIApplication()
        app.launchArguments = ["--complete"]
        app.launch()
        app.buttons["composer.voice"].tap()
        XCTAssertTrue(app.buttons["voice.microphone"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Hey Jordan! What's on your mind tonight?"].exists)
        XCTAssertFalse(app.buttons["Copy response"].exists)
        XCTAssertFalse(app.staticTexts["Claude is AI and can make mistakes."].exists)
        capture("voice-inline")
        app.buttons["voice.output"].tap()
        XCTAssertEqual(app.buttons["voice.output"].value as? String, "Muted")
        app.buttons["voice.settings"].tap()
        XCTAssertTrue(app.staticTexts["Voice settings"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.buttons["voice.choice.Suave"].frame.midX, app.frame.midX, accuracy: 5)
        capture("voice-settings")
        app.buttons["voice.choice.Clara"].tap()
        XCTAssertEqual(app.buttons["voice.choice.Clara"].frame.midX, app.frame.midX, accuracy: 5)
        app.buttons["voice.choice.Suave"].tap()
        XCTAssertEqual(app.buttons["voice.choice.Suave"].frame.midX, app.frame.midX, accuracy: 5)
        app.buttons["voice.settings.model"].tap()
        XCTAssertTrue(app.staticTexts["Select model"].waitForExistence(timeout: 2))
        capture("voice-models")
        app.buttons["model.Sonnet 5.5"].tap()
        app.buttons["Close"].tapWhenSettled()
        app.buttons["voice.exit"].tapWhenSettled()
        XCTAssertTrue(app.buttons["composer.voice"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Copy response"].exists)
        XCTAssertTrue(app.staticTexts["Claude is AI and can make mistakes."].exists)
        XCTAssertTrue(app.buttons["composer.model"].label.contains("Sonnet 5.5"))
        XCTAssertTrue(app.staticTexts["Voice chat ended"].exists)
        capture("voice-ended")
        app.buttons["Good voice chat"].tap()
        XCTAssertEqual(app.buttons["Good voice chat"].value as? String, "Selected")
        app.buttons["voice.summary.dismiss"].tap()
        XCTAssertFalse(app.staticTexts["Voice chat ended"].exists)
    }
}
