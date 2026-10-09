@testable import ClaudeUI
import SwiftUI
import Testing
import UIKit

@testable import ClaudeUIDemo

/// One light and one dark reference image for every `DemoScreen`, rendered with the same `DemoScreenView` the
/// demo app shows for `--screen <name>`, plus the model picker, which only the package can construct.
@MainActor @Suite(.serialized) struct ScreenSnapshotTests {
    nonisolated static let appearances: [UIUserInterfaceStyle] = [.light, .dark]

    @Test(arguments: DemoScreen.allCases, appearances)
    func screen(_ id: DemoScreen, appearance: UIUserInterfaceStyle) async throws {
        try await Screen.assertSnapshot(
            DemoScreenView(screen: id, appearance: appearance == .light ? .light : .dark), named: id.rawValue,
            appearance: appearance, testName: "screen")
    }

    /// `ClaudeModelSheet` is internal to the package, so the demo app cannot open it by name; users reach it from
    /// the composer's model button, which `AccessibilityAuditUITests` taps.
    @Test(arguments: appearances)
    func modelsSheet(appearance: UIUserInterfaceStyle) async throws {
        var state = SessionState()
        state.installDemoFixtures()
        state.appearance = appearance == .light ? .light : .dark
        let host = SessionHost(state: state) { AnyView(ClaudeModelSheet(state: $0, action: { _ in })) }
        try await Screen.assertSnapshot(host, named: "modelsSheet", appearance: appearance, testName: "screen")
    }
}
