import XCTest

final class SettingsCapabilitiesUITests: XCTestCase {

    @MainActor func testCapabilitiesHostTruthAndMemoryFileDeleteCancel() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light", "--memory-clear-after-submit"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tap()
            let route = app.buttons["settings.route.Capabilities"]
            if !route.isHittable { app.scrollViews["settings.root.scroll"].swipeUp() }
            route.tap()
            let artifacts = app.switches["settings.capability.artifacts"]
            XCTAssertTrue(artifacts.waitForExistence(timeout: 3))
            XCTAssertFalse(artifacts.isEnabled)
            XCTAssertEqual(artifacts.value as? String, "1")
            capture("settings-capabilities-" + appearance)
            app.switches["settings.capability.inlineVisualizations"].tap()
            XCTAssertEqual(app.switches["settings.capability.inlineVisualizations"].value as? String, "1")
            let memoryRoute = app.buttons["settings.capabilities.memoryFiles"]
            for _ in 0..<3 {
                if memoryRoute.isHittable { break }
                app.scrollViews["settings.capabilities.scroll"].swipeUp()
            }
            XCTAssertTrue(memoryRoute.isHittable)
            capture("settings-capabilities-memory-" + appearance)
            let sensitive = app.switches["settings.capability.sensitiveMemory"]
            sensitive.tap()
            XCTAssertEqual(sensitive.value as? String, "0")
            memoryRoute.tap()
            XCTAssertTrue(app.buttons["settings.memory.file.coding"].waitForExistence(timeout: 3))
            capture("settings-memory-files-" + appearance)
            XCTAssertFalse(app.buttons["settings.memory.send"].isEnabled)
            app.buttons["settings.memory.file.coding"].tap()
            XCTAssertTrue(app.buttons["settings.memory.delete"].waitForExistence(timeout: 3))
            capture("settings-memory-detail-" + appearance)
            app.buttons["settings.memory.delete"].tap()
            XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 3))
            capture("settings-memory-delete-" + appearance)
            app.alerts.buttons["Cancel"].tap()
            XCTAssertTrue(app.buttons["settings.memory.delete"].isEnabled)
            let draft = app.descendants(matching: .any).matching(identifier: "settings.memory.draft").firstMatch
            draft.tapToFocus()
            draft.typeText("Remember herbs.")
            XCTAssertEqual(draft.value as? String, "Remember herbs.")
            app.buttons["settings.memory.send"].tap()
            XCTAssertEqual(draft.value as? String, appearance == "light" ? "" : "Remember herbs.")
            app.buttons["settings.memory.delete"].tap()
            app.alerts.buttons["Delete"].tap()
            XCTAssertTrue(app.buttons["settings.memory.delete"].exists)
            XCTAssertFalse(app.buttons["settings.memory.delete"].isEnabled)
            app.buttons["settings.back"].tap()
            XCTAssertTrue(app.buttons["settings.memory.file.coding"].exists)
            app.buttons["settings.memory.file.coding"].tap()
            XCTAssertTrue(app.buttons["settings.memory.delete"].isEnabled)
            app.buttons["settings.back"].tap()
            app.buttons["settings.back"].tap()
            XCTAssertTrue(app.buttons["settings.capabilities.memoryFiles"].exists)
            app.terminate()
        }
    }
}
