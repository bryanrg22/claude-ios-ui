import XCTest

final class DevicesDispatchUITests: XCTestCase {
    @MainActor func testDevicesManageAccountAndClosePreserveConversation() {
        let app = XCUIApplication()
        app.launchArguments = ["--complete"]
        app.launch()
        app.buttons["header.devices"].tap()
        let device = app.descendants(matching: .any)["devices.row.sample-desktop"].firstMatch
        XCTAssertTrue(device.waitForExistence(timeout: 3))
        XCTAssertTrue(device.label.contains("Connected"))
        device.tap()
        XCTAssertTrue(app.buttons["devices.manage"].exists)
        capture("devices-connected")
        app.buttons["devices.manage"].tap()
        let name = app.textFields["devices.profile.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 3))
        XCTAssertEqual(name.value as? String, "Jordan Lee")
        capture("manage-devices-account")
        app.scrollViews["devices.account.scroll"].swipeUp()
        XCTAssertTrue(app.buttons["devices.logout"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["devices.delete"].isEnabled)
        app.buttons["devices.logout"].tap()
        XCTAssertTrue(app.buttons["devices.organization.copy"].exists)
        capture("manage-devices-bottom")
        app.buttons["sheet.close.Manage devices"].tap()
        app.buttons["sheet.close.Devices"].tapWhenSettled()
        XCTAssertTrue(app.staticTexts["Hey Jordan! What's on your mind tonight?"].waitForExistence(timeout: 2))
    }

    @MainActor func testDispatchSidebarNavigationDraftAndReturnToChat() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["sidebar.open"].tap()
        app.buttons.containing(.staticText, identifier: "Dispatch").firstMatch.tapWhenSettled()
        XCTAssertTrue(app.textFields["dispatch.draft"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Online"].exists)
        XCTAssertTrue(app.staticTexts["Oct 7, 2026 at 9:11 PM"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["dispatch.send"].isEnabled)
        capture("dispatch-online")
        app.textFields["dispatch.draft"].tapToFocus()
        app.textFields["dispatch.draft"].typeText("Organize sample files")
        XCTAssertTrue(app.buttons["dispatch.send"].isEnabled)
        app.buttons["dispatch.send"].tap()
        XCTAssertEqual(app.textFields["dispatch.draft"].value as? String, "Organize sample files")
        app.buttons["sidebar.open"].tap()
        app.buttons.containing(.staticText, identifier: "New session").firstMatch.tapWhenSettled()
        XCTAssertTrue(app.buttons["composer.voice"].waitForExistence(timeout: 3))
    }
}
