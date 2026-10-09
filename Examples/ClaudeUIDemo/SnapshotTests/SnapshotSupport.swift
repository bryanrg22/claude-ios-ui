import SnapshotTesting
import SwiftUI
import Testing
import UIKit

/// Screenshot tests render each screen in a real on-screen window of the host app, so iOS materials (Liquid Glass),
/// safe areas and system controls draw exactly as they do in the running demo. Offscreen rendering drops
/// materials and safe areas, which is why the library's default view strategies are not used here.
///
/// Every capture gets a brand-new window. Liquid Glass adapts to what was on screen before it, so reusing one
/// window let the previous screen change the next screen's glass tint (measured: the same button rendered at
/// three different grays depending on test order).
///
/// References must be recorded on the configuration CI uses: an iPhone 15 Pro simulator on iOS 27.0.
/// Missing references are recorded automatically (and that run fails). To re-record after an intentional visual
/// change, run with `TEST_RUNNER_SNAPSHOT_TESTING_RECORD=all xcodebuild test ...`, review every changed PNG, then
/// commit them.
@MainActor enum Screen {
    static let expectedSize = CGSize(width: 393, height: 852)
    static let imageScale: CGFloat = 1

    /// - Parameters:
    ///   - precision: Fraction of pixels that must match. The default allows about 350 pixels (0.1%) of noise.
    ///   - settle: Time for layout, images and Liquid Glass adaptation to finish before capture. Glass over a
    ///     freshly presented card was measured to keep changing until 1.5 s, so the default is 2 s.
    static func assertSnapshot<Content: View>(
        _ content: Content, named name: String, appearance: UIUserInterfaceStyle,
        precision: Double = 0.999, settle: Duration = .seconds(2), fileID: StaticString = #fileID,
        file: StaticString = #filePath,
        testName: String = #function, line: UInt = #line, column: UInt = #column
    ) async throws {
        let hostWindow = try #require(
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap(\.windows).first {
                $0.isKeyWindow
            }, "Snapshot tests must run hosted in the demo app")
        let scene = try #require(hostWindow.windowScene)
        let window = UIWindow(windowScene: scene)
        try #require(
            window.bounds.size == expectedSize,
            "References were recorded on \(expectedSize.width)×\(expectedSize.height) pt; this simulator is \(window.bounds.size)"
        )
        defer {
            window.isHidden = true
            window.rootViewController = nil
            hostWindow.makeKeyAndVisible()
        }
        window.overrideUserInterfaceStyle = appearance
        window.rootViewController = UIHostingController(rootView: content.transaction { $0.disablesAnimations = true })
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        try await Task.sleep(for: settle)
        window.layoutIfNeeded()

        let format = UIGraphicsImageRendererFormat()
        format.scale = imageScale
        format.opaque = true
        // 8-bit sRGB. The default wide-color (16-bit Display P3) capture carries sub-visible run-to-run noise in
        // gradients and glass that the perceptual comparison reports as large differences.
        format.preferredRange = .standard
        let image = UIGraphicsImageRenderer(bounds: window.bounds, format: format).image { _ in
            _ = window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        SnapshotTesting.assertSnapshot(
            of: image, as: .image(precision: Float(precision), perceptualPrecision: 0.98, scale: imageScale),
            named: name + (appearance == .dark ? "-dark" : "-light"), fileID: fileID, file: file,
            testName: testName, line: line, column: column)
    }
}
