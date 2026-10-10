import XCTest

final class SettingsPreferencesUITests: XCTestCase {

    @MainActor func testNotificationPreferencesPersistAcrossSettings() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["sidebar.open"].tap()
        app.buttons["sidebar.settings"].tapWhenSettled()
        app.buttons["settings.route.Notifications"].tapWhenSettled()
        XCTAssertTrue(app.switches["settings.notification.replies"].waitForExistence(timeout: 3))
        capture("settings-notifications-dark")
        for key in [
            "replies", "scheduledTasks", "researchComplete", "codeUpdates", "codePermissions", "dispatchMessages",
            "productUpdates"
        ] {
            let toggle = app.switches["settings.notification." + key]
            if !toggle.isHittable { app.scrollViews["settings.notifications.scroll"].swipeUp() }
            XCTAssertEqual(toggle.value as? String, "1")
            toggle.tap()
            XCTAssertEqual(toggle.value as? String, "0")
        }
        app.buttons["settings.back"].tap()
        app.buttons["settings.back"].tapWhenSettled()
        app.buttons["sidebar.settings"].tapWhenSettled()
        app.buttons["settings.route.Notifications"].tapWhenSettled()
        XCTAssertEqual(app.switches["settings.notification.replies"].value as? String, "0")
        app.buttons["settings.back"].tap()
        app.buttons["settings.back"].tapWhenSettled()
        app.terminate()
        app.launchArguments = ["--light"]
        app.launch()
        app.buttons["sidebar.open"].tap()
        app.buttons["sidebar.settings"].tapWhenSettled()
        app.buttons["settings.route.Notifications"].tapWhenSettled()
        XCTAssertTrue(app.switches["settings.notification.replies"].waitForExistence(timeout: 3))
        capture("settings-notifications-light")
    }

    @MainActor func testTimeFocusCapturedPickersAndLocalPreferencePersistence() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["sidebar.open"].tap()
        app.buttons["sidebar.settings"].tapWhenSettled()
        app.buttons["settings.route.Time & focus"].tapWhenSettled()
        let hours = app.buttons["settings.focus.hours"]
        let minutes = app.buttons["settings.focus.minutes"]
        XCTAssertTrue(hours.waitForExistence(timeout: 3))
        XCTAssertEqual(hours.value as? String, "-")
        capture("settings-time-focus-dark")
        hours.tap()
        XCTAssertTrue(app.buttons["settings.focus.choice.12"].waitForExistence(timeout: 3))
        capture("settings-time-focus-hours")
        app.buttons["settings.focus.choice.2"].tap()
        XCTAssertEqual(hours.value as? String, "2 hr")
        minutes.tap()
        XCTAssertTrue(app.buttons["settings.focus.choice.45"].waitForExistence(timeout: 3))
        capture("settings-time-focus-minutes")
        XCTAssertFalse(app.buttons["settings.focus.choice.60"].exists)
        app.buttons["settings.focus.choice.30"].tap()
        XCTAssertEqual(minutes.value as? String, "30 min")
        app.buttons["settings.focus.day.sunday"].tap()
        XCTAssertEqual(hours.value as? String, "2 hr")
        app.buttons["settings.back"].tap()
        app.buttons["settings.route.Time & focus"].tapWhenSettled()
        XCTAssertEqual(hours.value as? String, "2 hr")
        XCTAssertEqual(minutes.value as? String, "30 min")
        hours.tap()
        app.buttons["settings.focus.choice.none"].tapWhenSettled()
        minutes.tapWhenSettled()
        app.buttons["settings.focus.choice.none"].tapWhenSettled()
        XCTAssertEqual(hours.value as? String, "-")
        XCTAssertEqual(minutes.value as? String, "-")
        app.terminate()
        app.launchArguments = ["--light"]
        app.launch()
        app.buttons["sidebar.open"].tap()
        app.buttons["sidebar.settings"].tapWhenSettled()
        app.buttons["settings.route.Time & focus"].tapWhenSettled()
        XCTAssertTrue(hours.waitForExistence(timeout: 3))
        capture("settings-time-focus-light")
    }

    @MainActor func testPrivacyConsentIsHostOwnedInBothAppearances() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tapWhenSettled()
            app.buttons["settings.route.Privacy"].tapWhenSettled()
            let consent = app.switches["settings.privacy.modelImprovement"]
            XCTAssertTrue(consent.waitForExistence(timeout: 3))
            XCTAssertEqual(consent.value as? String, "1")
            capture("settings-privacy-" + appearance)
            consent.tap()
            XCTAssertEqual(consent.value as? String, "1")
            XCTAssertTrue(app.staticTexts["Data privacy"].exists)
            app.buttons["settings.back"].tap()
            app.buttons["settings.route.Privacy"].tapWhenSettled()
            XCTAssertEqual(consent.value as? String, "1")
            app.terminate()
        }
    }

    @MainActor func testCodePreferencesMenusSliderAndNavigationPersistence() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tapWhenSettled()
            let route = app.buttons["settings.route.Claude Code"]
            if !route.isHittable { app.scrollViews["settings.root.scroll"].swipeUp() }
            route.tap()
            let slider = app.sliders["settings.code.size"]
            XCTAssertTrue(slider.waitForExistence(timeout: 3))
            capture("settings-code-" + appearance)
            app.buttons["settings.code.transcriptFont"].tap()
            XCTAssertTrue(app.buttons["System"].waitForExistence(timeout: 3))
            capture("settings-code-transcript-menu-" + appearance)
            app.buttons["System"].tap()
            XCTAssertTrue(app.buttons["settings.code.transcriptFont"].label.contains("System"))
            app.buttons["settings.code.codeFont"].tap()
            XCTAssertTrue(app.buttons["JetBrains Mono"].waitForExistence(timeout: 3))
            capture("settings-code-font-menu-" + appearance)
            app.buttons["JetBrains Mono"].tap()
            slider.adjust(toNormalizedSliderPosition: 0.8)
            let changedValue = slider.value as? String
            XCTAssertNotEqual(changedValue, "50%")
            app.switches["settings.code.wrap"].tap()
            XCTAssertEqual(app.switches["settings.code.wrap"].value as? String, "1")
            app.buttons["settings.back"].tap()
            if !route.isHittable { app.scrollViews["settings.root.scroll"].swipeUp() }
            route.tap()
            XCTAssertEqual(slider.value as? String, changedValue)
            XCTAssertTrue(app.buttons["settings.code.codeFont"].label.contains("JetBrains Mono"))
            XCTAssertEqual(app.switches["settings.code.wrap"].value as? String, "1")
            app.terminate()
        }
    }
}
