import XCTest

final class SettingsConnectorsUITests: XCTestCase {

    @MainActor func testSettingsConnectorsHostOnlyPolicyAndBackNavigation() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tap()
            let route = app.buttons["settings.route.Connectors"]
            if !route.isHittable { app.scrollViews["settings.root.scroll"].swipeUp() }
            route.tap()
            let discovery = app.switches["settings.connectors.discovery"]
            XCTAssertTrue(discovery.waitForExistence(timeout: 3))
            capture("settings-connectors-" + appearance)
            discovery.tap()
            XCTAssertEqual(discovery.value as? String, "1")

            app.buttons["settings.connector.notes"].tap()
            XCTAssertTrue(discovery.exists)
            app.buttons["settings.connector.design"].tap()
            XCTAssertTrue(app.buttons["settings.connector.tool.create"].waitForExistence(timeout: 3))
            capture("settings-connector-tools-" + appearance)
            app.buttons["settings.connector.allTools"].tap()
            XCTAssertTrue(app.buttons["settings.connector.policy.Always allow"].waitForExistence(timeout: 2))
            capture("settings-connector-all-tools-" + appearance)
            XCTAssertFalse(app.buttons["settings.connector.policy.Needs approval"].isSelected)
            app.buttons["settings.connector.policy.Always allow"].tap()
            XCTAssertFalse(app.buttons["settings.connector.policy.Always allow"].isSelected)
            app.buttons["settings.back"].tap()
            app.buttons["settings.connector.tool.create"].tap()
            XCTAssertTrue(app.buttons["settings.connector.policy.Needs approval"].waitForExistence(timeout: 3))
            capture("settings-connector-policy-" + appearance)
            XCTAssertTrue(app.buttons["settings.connector.policy.Needs approval"].isSelected)
            app.buttons["settings.connector.policy.Always allow"].tap()
            XCTAssertTrue(app.buttons["settings.connector.policy.Needs approval"].isSelected)
            app.buttons["settings.back"].tap()
            XCTAssertTrue(app.buttons["settings.connector.tool.create"].exists)
            app.buttons["settings.back"].tap()
            XCTAssertTrue(discovery.exists)
            app.buttons["settings.back"].tap()
            XCTAssertTrue(app.buttons["settings.route.Profile"].exists)
            app.terminate()
        }
    }

    @MainActor func testConnectorCatalogFiltersAndCustomDraftCancellation() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tap()
            let route = app.buttons["settings.route.Connectors"]
            if !route.isHittable { app.scrollViews["settings.root.scroll"].swipeUp() }
            route.tap()
            app.buttons["settings.connectors.add"].tap()
            capture("settings-connectors-add-" + appearance)
            app.buttons["Browse connectors"].tap()
            XCTAssertTrue(app.buttons["settings.catalog.sort"].waitForExistence(timeout: 3))
            capture("settings-catalog-" + appearance)
            app.buttons["settings.catalog.sort"].tap()
            capture("settings-catalog-sort-" + appearance)
            app.buttons["Consumer health"].tap()
            XCTAssertTrue(app.buttons["settings.catalog.connect.research"].waitForExistence(timeout: 2))
            XCTAssertFalse(app.buttons["settings.catalog.connect.design"].exists)
            capture("settings-catalog-health-" + appearance)
            app.buttons["settings.catalog.connect.research"].tap()
            XCTAssertTrue(app.buttons["settings.catalog.connect.research"].exists)
            let search = app.textFields["settings.catalog.search"]
            search.tapToFocus()
            search.typeText("Trail")
            XCTAssertTrue(app.buttons["settings.catalog.connect.trails"].exists)
            XCTAssertFalse(app.buttons["settings.catalog.connect.research"].exists)
            app.buttons["settings.catalog.close"].tap()
            app.buttons["settings.connectors.add"].tap()
            app.buttons["Add custom connector"].tap()
            let name = app.textFields["settings.custom.name"]
            XCTAssertTrue(name.waitForExistence(timeout: 3))
            XCTAssertTrue(app.buttons["settings.catalog.close"].isHittable)
            Thread.sleep(forTimeInterval: 2)
            capture("settings-custom-empty-" + appearance)
            XCTAssertFalse(app.buttons["settings.custom.continue"].isEnabled)
            name.tapToFocus()
            name.typeText("Example tools")
            XCTAssertEqual(name.value as? String, "Example tools")
            let url = app.textFields["settings.custom.url"]
            url.tapToFocus()
            url.typeText("https://example.com/mcp")
            XCTAssertEqual(url.value as? String, "https://example.com/mcp")
            XCTAssertTrue(app.buttons["settings.custom.continue"].isEnabled)
            app.buttons["settings.catalog.close"].tap()
            app.buttons["settings.connectors.add"].tap()
            app.buttons["Add custom connector"].tap()
            XCTAssertFalse(app.buttons["settings.custom.continue"].isEnabled)
            XCTAssertEqual(app.textFields["settings.custom.name"].value as? String, "Name")
            app.buttons["settings.catalog.close"].tap()
            app.terminate()
        }
    }
}
