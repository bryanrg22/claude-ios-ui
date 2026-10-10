import XCTest

final class ArtifactsUITests: XCTestCase {
    @MainActor func testArtifactsFiltersDocumentCollapseAndReturn() {
        let app = XCUIApplication()
        app.launchArguments = ["--artifacts"]
        app.launch()
        XCTAssertTrue(app.buttons["artifact.row.garden"].waitForExistence(timeout: 3))
        capture("artifacts-list")
        app.buttons["artifacts.filter"].tap()
        XCTAssertTrue(app.buttons["Shared with you"].waitForExistence(timeout: 2))
        capture("artifacts-filter")
        app.buttons["Pinned"].tap()
        XCTAssertTrue(app.buttons["artifact.row.garden"].exists)
        XCTAssertFalse(app.buttons["artifact.row.workshop"].exists)
        app.buttons["artifacts.filter"].tap()
        app.buttons["All"].tapWhenSettled()
        app.buttons["artifact.row.garden"].tapWhenSettled()
        XCTAssertTrue(app.buttons["artifact.section.overview"].waitForExistence(timeout: 2))
        capture("artifact-document")
        XCTAssertFalse(app.buttons["artifact.undo"].isEnabled)
        XCTAssertFalse(app.buttons["artifact.redo"].isEnabled)
        app.buttons["artifact.section.overview"].tap()
        XCTAssertFalse(
            app.staticTexts[
                "A neighborhood garden gives people a place to learn together, share seasonal produce, and enjoy a quiet afternoon outside."
            ].exists)
        app.buttons["artifact.section.overview"].tap()
        app.buttons["artifact.collapse-title"].tapWhenSettled()
        XCTAssertFalse(app.buttons["artifact.section.overview"].exists)
        app.buttons["artifact.collapse-title"].tap()
        app.buttons["artifact.comments"].tapWhenSettled()
        app.buttons["artifact.share"].tapWhenSettled()
        app.buttons["artifact.tabs"].tapWhenSettled()
        XCTAssertTrue(app.buttons["artifact.section.overview"].waitForExistence(timeout: 3))
        app.buttons["artifact.back"].tap()
        XCTAssertTrue(app.buttons["artifact.row.garden"].exists)
        app.buttons["sidebar.open"].tap()
        app.buttons.containing(.staticText, identifier: "New session").firstMatch.tapWhenSettled()
        XCTAssertTrue(app.buttons["composer.voice"].waitForExistence(timeout: 2))
    }
}
