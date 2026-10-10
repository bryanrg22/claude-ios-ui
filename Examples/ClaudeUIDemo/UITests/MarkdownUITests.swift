import XCTest

final class MarkdownUITests: XCTestCase {
    @MainActor func testMarkdownFormattingCopyAndSelectionInBothAppearances() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = ["--markdown"] + (appearance == "light" ? ["--light"] : [])
            app.launch()
            XCTAssertTrue(app.staticTexts["A small garden"].waitForExistence(timeout: 4))
            capture("markdown-top-" + appearance)
            let paragraph = app.textViews["markdown.inlineCode"].firstMatch
            paragraph.press(forDuration: 1.1)
            XCTAssertTrue(app.buttons["Copy"].waitForExistence(timeout: 2) || app.menuItems["Copy"].exists)
            app.launch()
            // Targeted native auto-scroll remains stable when content height changes.
            app.buttons["markdown.code.copy"].tap()
            XCTAssertTrue(app.buttons["markdown.code.copy"].isHittable)
            capture("markdown-code-" + appearance)
            app.buttons["markdown.code.expand"].tap()
            XCTAssertTrue(app.buttons["markdown.code.close"].waitForExistence(timeout: 3))
            XCTAssertLessThan(app.staticTexts["markdown.code.expandedContent"].frame.minY, 220)
            capture("markdown-expanded-" + appearance)
            app.buttons["markdown.code.close"].tap()
            app.buttons["markdown.code.copy"].tapWhenSettled()
            let draft = app.textFields["composer.draft"]
            draft.tap()
            draft.press(forDuration: 1.1)
            if app.buttons["Paste"].waitForExistence(timeout: 2) {
                app.buttons["Paste"].tap()
            } else {
                app.menuItems["Paste"].tap()
            }
            XCTAssertEqual(draft.value as? String, "def greet(name: str) -> str:\n    return f\"Hello, {name}!\"\n")
            app.launch()
            app.swipeUp()
            capture("markdown-table-" + appearance)
            XCTAssertTrue(app.staticTexts["Mint"].exists)
            XCTAssertTrue(app.staticTexts["Season"].isHittable)
            let compact = app.scrollViews["markdown.table"].firstMatch
            XCTAssertLessThanOrEqual(app.staticTexts["Season"].frame.maxX, compact.frame.maxX)
            capture("markdown-table-compact-" + appearance)
            app.swipeUp()
            app.scrollViews.matching(identifier: "markdown.table").element(boundBy: 1).swipeLeft()
            XCTAssertTrue(app.staticTexts["Last updated"].isHittable)
            capture("markdown-table-scrolled-" + appearance)
            XCTAssertTrue(app.buttons["composer.voice"].exists)
        }
    }
}
