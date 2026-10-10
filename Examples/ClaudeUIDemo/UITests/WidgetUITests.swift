import XCTest

final class WidgetUITests: XCTestCase {
    @MainActor func testWidgetPreviewLinksRouteToOfflineScreens() {
        let app = XCUIApplication()
        let cases = [
            ("quickActionsSmall.chat", "composer.voice"), ("quickActionsSmall.camera", "camera.cancel"),
            ("quickActionsSmall.voice", "voice.exit"), ("quickActionsMedium.code", "code.add-device"),
            ("quickActionsMedium.dispatch", "dispatch.send"), ("codeSmall.newCodeSession", "code.draft.back"),
            ("codeSmall.searchCode", "code.search")
        ]
        for (index, route) in cases.enumerated() {
            app.launchArguments = ["--widgets"]
            app.launch()
            let link = app.descendants(matching: .any)["widget." + route.0].firstMatch
            XCTAssertTrue(link.waitForExistence(timeout: 3))
            if index == 0 { capture("widgets-preview") }
            link.tap()
            XCTAssertTrue(app.buttons[route.1].waitForExistence(timeout: 3))
        }
    }
    /// Native SpringBoard tests are opt-in because they modify a simulator Home Screen.
    @MainActor func testWidgetNativeGalleryVariants() throws {
        guard ProcessInfo.processInfo.environment["CLAUDE_NATIVE_WIDGET_TESTS"] == "1" else {
            throw XCTSkip("Set CLAUDE_NATIVE_WIDGET_TESTS=1 on the test runner for native gallery validation")
        }
        let app = XCUIApplication()
        app.launch()
        XCUIDevice.shared.press(.home)
        Thread.sleep(forTimeInterval: 2)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        func nativeCapture(_ name: String) {
            let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        guard
            let icon = springboard.icons.matching(identifier: "Claude UI Demo").allElementsBoundByIndex.first(where: {
                $0.isHittable
            })
        else {
            XCTFail("Installed demo app icon missing")
            return
        }
        icon.press(forDuration: 1.2)
        springboard.buttons["Edit Home Screen"].tap()
        springboard.buttons["Edit"].tapWhenSettled()
        springboard.buttons["Add Widget"].tapWhenSettled()
        XCTAssertTrue(springboard.cells["Claude UI Demo"].waitForExistence(timeout: 4))
        springboard.cells["Claude UI Demo"].tap()
        guard let page = springboard.pageIndicators.allElementsBoundByIndex.first(where: { $0.frame.width > 300 })
        else {
            XCTFail("Native gallery page indicator missing")
            return
        }
        func pageIs(_ number: Int) -> Bool { page.value as? String == "page \(number) of 3" }
        func move(to number: Int, left: Bool) {
            for _ in 0..<3 {
                if pageIs(number) { return }
                let start = springboard.coordinate(withNormalizedOffset: CGVector(dx: left ? 0.88 : 0.12, dy: 0.58))
                let end = springboard.coordinate(withNormalizedOffset: CGVector(dx: left ? 0.12 : 0.88, dy: 0.58))
                start.press(forDuration: 0.05, thenDragTo: end)
                _ = XCTWaiter.wait(
                    for: [
                        XCTNSPredicateExpectation(
                            predicate: NSPredicate(format: "value == %@", "page \(number) of 3"), object: page)
                    ], timeout: 2)
            }
            XCTAssertTrue(pageIs(number))
        }
        XCTAssertTrue(page.waitForExistence(timeout: 4))
        XCTAssertTrue(pageIs(1))
        nativeCapture("widget-native-quick-small")
        move(to: 2, left: true)
        nativeCapture("widget-native-quick-medium")
        move(to: 3, left: true)
        XCTAssertTrue(springboard.staticTexts["Code shortcuts"].exists)
        nativeCapture("widget-native-code-small")
        springboard.buttons["close"].tap()
        if springboard.buttons["Done"].waitForExistence(timeout: 3) { springboard.buttons["Done"].tap() }
    }
    @MainActor func testWidgetInstalledSmallLinks() throws {
        guard ProcessInfo.processInfo.environment["CLAUDE_NATIVE_WIDGET_TESTS"] == "1" else {
            throw XCTSkip("Install the small Quick Actions widget and enable CLAUDE_NATIVE_WIDGET_TESTS=1")
        }
        let app = XCUIApplication()
        app.launchArguments = []
        app.launch()
        XCUIDevice.shared.press(.home)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for route in [("camera", "camera.cancel"), ("voice", "voice.exit"), ("chat", "composer.voice")] {
            let link = springboard.buttons["widget.quickActionsSmall." + route.0]
            XCTAssertTrue(link.waitForExistence(timeout: 4))
            link.tap()
            XCTAssertTrue(app.buttons[route.1].waitForExistence(timeout: 4))
            XCUIDevice.shared.press(.home)
        }
        Thread.sleep(forTimeInterval: 2)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "widget-native-installed"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
