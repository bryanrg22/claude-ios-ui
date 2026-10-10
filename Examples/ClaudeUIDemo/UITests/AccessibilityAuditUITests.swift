import XCTest

/// Runs Apple's accessibility audit on every `DemoScreen`, plus the model picker, in light and dark appearance.
///
/// Issues that already exist are listed in `AccessibilityAuditBaseline.txt`, one per line. The test fails on any
/// issue that is not in that file, so changes cannot make accessibility worse. Fixing an issue means deleting its
/// line. To regenerate the file after an intentional change, run this test with the environment variable
/// `TEST_RUNNER_ACCESSIBILITY_AUDIT_RECORD=1` and review the diff before committing it.
final class AccessibilityAuditUITests: XCTestCase {
    private static let baselineURL = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        .appendingPathComponent("AccessibilityAuditBaseline.txt")

    @MainActor func testEveryScreenPassesAccessibilityAudit() throws {
        let recording = ProcessInfo.processInfo.environment["ACCESSIBILITY_AUDIT_RECORD"] == "1"
        let baseline = recording ? [] : try Self.loadBaseline()
        var found: Set<String> = []
        var unexpected: [String] = []
        let app = XCUIApplication()
        func audit(_ screen: String, _ appearance: String) throws {
            try app.performAccessibilityAudit { issue in
                let key = Self.key(for: issue, screen: screen, appearance: appearance)
                found.insert(key)
                if !recording, !baseline.contains(key) { unexpected.append(key) }
                return true  // Reported below, all together, instead of one failure per issue.
            }
        }
        for appearance in ["light", "dark"] {
            let appearanceArguments = appearance == "light" ? ["--light"] : []
            for screen in DemoScreen.allCases {
                app.launchArguments = ["--screen", screen.rawValue] + appearanceArguments
                app.launch()
                XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 10), "\(screen) did not launch")
                try audit(screen.rawValue, appearance)
                app.terminate()
            }
            // The model picker is internal to the package; open it from the composer as a user would.
            app.launchArguments = appearanceArguments
            app.launch()
            XCTAssertTrue(app.buttons["composer.model"].waitForExistence(timeout: 10))
            app.buttons["composer.model"].tap()
            XCTAssertTrue(app.buttons["model.Haiku 5.5"].waitForExistence(timeout: 5))
            try audit("modelsSheet", appearance)
            app.terminate()
        }
        if recording {
            try (found.sorted().joined(separator: "\n") + "\n").write(
                to: Self.baselineURL, atomically: true, encoding: .utf8)
            return
        }
        XCTAssertTrue(
            unexpected.isEmpty,
            "\(unexpected.count) new accessibility issue(s), not in AccessibilityAuditBaseline.txt:\n"
                + unexpected.sorted().joined(separator: "\n"))
        let fixed = baseline.subtracting(found)
        if !fixed.isEmpty {
            print(
                "\(fixed.count) baseline issue(s) no longer occur; delete these lines:\n"
                    + fixed.sorted().joined(separator: "\n"))
        }
    }

    /// `screen | appearance | audit type | element`, stable across runs for the same UI. Identifiers that embed a
    /// per-launch UUID (for example `row.<UUID>`) are normalized so the same element keeps the same key.
    private static func key(for issue: XCUIAccessibilityAuditIssue, screen: String, appearance: String) -> String {
        let element =
            issue.element.map {
                let identifier = $0.identifier.replacingOccurrences(
                    of: "[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}", with: "<uuid>",
                    options: .regularExpression)
                return "\($0.elementType.rawValue):\(identifier):\($0.label)"
            } ?? "none"
        let line = [screen, appearance, issue.compactDescription, element].joined(separator: " | ")
        return line.replacingOccurrences(of: "\n", with: " ")
    }

    private static func loadBaseline() throws -> Set<String> {
        let text = try String(contentsOf: baselineURL, encoding: .utf8)
        return Set(text.split(separator: "\n").map(String.init).filter { !$0.isEmpty })
    }
}
