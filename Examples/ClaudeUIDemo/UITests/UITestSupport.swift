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
