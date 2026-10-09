import XCTest

final class AnnouncementUITests: XCTestCase {

    @MainActor func testWorkAnnouncementStillAndBothDismissalButtons() {
        let app = XCUIApplication()
        for button in ["announcement.dismiss", "announcement.close"] {
            app.launchArguments = ["--announcement"]
            app.launch()
            XCTAssertTrue(app.buttons[button].waitForExistence(timeout: 3))
            XCTAssertTrue(app.staticTexts["One Claude for your work"].exists)
            capture("work-announcement-still")
            app.buttons[button].tap()
            XCTAssertTrue(app.buttons["composer.voice"].waitForExistence(timeout: 3))
            app.terminate()
        }
    }
}
