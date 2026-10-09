import XCTest

final class SettingsProfileUITests: XCTestCase {

    @MainActor func testSettingsProfileDraftCancelAndLocalSaveInBothAppearances() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tap()
            XCTAssertTrue(app.buttons["settings.route.Profile"].waitForExistence(timeout: 3))
            capture("settings-root-" + appearance)
            app.buttons["settings.about"].tap()
            XCTAssertTrue(app.buttons["Usage Policy"].waitForExistence(timeout: 3))
            capture("settings-info-" + appearance)
            app.buttons["Usage Policy"].tap()
            app.buttons["settings.route.Profile"].tap()
            let nickname = app.textFields["settings.profile.nickname"]
            XCTAssertTrue(nickname.waitForExistence(timeout: 3))
            XCTAssertEqual(nickname.value as? String, "Jordan")
            capture("settings-profile-" + appearance)
            app.buttons["settings.profile.photo"].tap()
            XCTAssertTrue(app.buttons["View photo library"].waitForExistence(timeout: 3))
            capture("settings-photo-menu-" + appearance)
            app.buttons["View photo library"].tap()

            app.buttons["settings.profile.instructions"].tap()
            let editor = app.textViews["settings.instructions.editor"]
            XCTAssertTrue(editor.waitForExistence(timeout: 3))
            capture("settings-instructions-" + appearance)
            editor.tap()
            editor.typeText("Keep this draft private")
            app.buttons["settings.instructions.cancel"].tap()
            app.buttons["settings.profile.instructions"].tap()
            XCTAssertEqual(editor.value as? String, "")
            app.buttons["settings.instructions.cancel"].tap()

            nickname.tap()
            nickname.typeText(" draft")
            app.buttons["settings.back"].tap()
            app.buttons["settings.route.Profile"].tap()
            XCTAssertEqual(nickname.value as? String, "Jordan")
            nickname.tap()
            nickname.typeText(" saved")
            XCTAssertEqual(nickname.value as? String, "Jordan saved")
            app.buttons["settings.profile.save"].tap()
            XCTAssertTrue(app.buttons["settings.route.Profile"].waitForExistence(timeout: 3))
            app.buttons["settings.route.Profile"].tap()
            XCTAssertEqual(nickname.value as? String, "Jordan saved")
            app.buttons["settings.profile.delete"].tap()
            XCTAssertEqual(nickname.value as? String, "Jordan saved")
            app.buttons["settings.back"].tap()
            let scroll = app.scrollViews["settings.root.scroll"]
            scroll.swipeUp()
            scroll.swipeUp()
            XCTAssertTrue(app.switches["settings.haptics"].exists)
            capture("settings-appearance-" + appearance)
            let before = app.switches["settings.haptics"].value as? String
            app.switches["settings.haptics"].tap()
            app.buttons["settings.back"].tap()
            app.buttons["sidebar.settings"].tap()
            scroll.swipeUp()
            scroll.swipeUp()
            XCTAssertNotEqual(app.switches["settings.haptics"].value as? String, before)
            app.buttons["settings.back"].tap()
            app.terminate()
        }
    }
}
