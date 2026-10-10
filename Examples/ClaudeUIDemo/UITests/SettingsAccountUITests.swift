import XCTest

final class SettingsAccountUITests: XCTestCase {

    @MainActor func testUsageMetersAndHostOnlyCreditActionsInBothAppearances() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tapWhenSettled()
            app.buttons["settings.route.Usage"].tapWhenSettled()
            let creditToggle = app.switches["settings.usage.creditsEnabled"]
            XCTAssertTrue(creditToggle.waitForExistence(timeout: 3))
            XCTAssertEqual(creditToggle.value as? String, "0")
            XCTAssertTrue(app.staticTexts["12% used"].exists)
            XCTAssertTrue(app.staticTexts["40% used"].exists)
            capture("settings-usage-" + appearance)
            creditToggle.tap()
            XCTAssertEqual(creditToggle.value as? String, "0")
            app.buttons["settings.usage.refresh"].tap()
            app.buttons["settings.usage.info"].tapWhenSettled()
            XCTAssertTrue(app.staticTexts["12% used"].exists)
            app.scrollViews["settings.usage.scroll"].swipeUp()
            XCTAssertTrue(app.buttons["settings.usage.buy"].waitForExistence(timeout: 3))
            capture("settings-usage-footer-" + appearance)
            app.buttons["settings.usage.buy"].tap()
            XCTAssertEqual(app.staticTexts["settings.usage.balance"].label, "18 credits")
            app.buttons["settings.back"].tap()
            app.buttons["settings.route.Usage"].tapWhenSettled()
            XCTAssertEqual(creditToggle.value as? String, "0")
            app.terminate()
        }
    }

    @MainActor func testBillingNativeNoticeAndHostOnlyRestore() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tapWhenSettled()
            app.buttons["settings.route.Billing"].tapWhenSettled()
            XCTAssertTrue(app.buttons["settings.billing.manage"].waitForExistence(timeout: 3))
            capture("settings-billing-" + appearance)
            app.buttons["settings.billing.restore"].tap()
            XCTAssertEqual(app.staticTexts["settings.billing.plan"].label, "Max")
            app.buttons["settings.billing.manage"].tap()
            XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 3))
            capture("settings-billing-notice-" + appearance)
            app.alerts.buttons["OK"].tap()
            XCTAssertTrue(app.alerts.firstMatch.waitForNonExistence(timeout: 3))
            app.buttons["settings.billing.manage"].tap()
            app.alerts.buttons["Manage on claude.ai"].tapWhenSettled()
            XCTAssertEqual(app.staticTexts["settings.billing.plan"].label, "Max")
            app.terminate()
        }
    }
    @MainActor func testSharedLinksReadOnlyDetailBackAndAppearance() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tapWhenSettled()
            let route = app.buttons["settings.route.Shared links"]
            if !route.isHittable { app.scrollViews["settings.root.scroll"].swipeUp() }
            route.tap()
            XCTAssertTrue(app.buttons["settings.shared.row.garden"].waitForExistence(timeout: 3))
            capture("settings-shared-links-" + appearance)
            app.buttons["settings.shared.row.garden"].tap()
            XCTAssertTrue(app.staticTexts["settings.shared.disclaimer"].waitForExistence(timeout: 3))
            XCTAssertFalse(app.textFields["composer.draft"].isHittable)
            XCTAssertTrue(app.staticTexts["Shared by Jordan 1 week ago"].exists)
            capture("settings-shared-detail-" + appearance)
            app.buttons["settings.back"].tap()
            XCTAssertTrue(app.buttons["settings.shared.row.garden"].waitForExistence(timeout: 3))
            app.buttons["settings.back"].tap()
            XCTAssertTrue(app.buttons["settings.route.Profile"].exists)
            app.terminate()
        }
    }
}
