# Testing

Four test suites guard this project. CI always runs format, project-sync, unit and iOS 26 SDK build checks. Screenshot, UI and accessibility suites run automatically for public repositories; while private, run them manually from Actions (see [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)).

| Suite | Location | What it checks | Runs on |
|---|---|---|---|
| Unit tests | `Tests/ClaudeUITests` | Session reducer: sending, streaming, editing, dictation, voice, Code, settings acknowledgements, Markdown and syntax highlighting | macOS host (`swift test`) |
| Screenshot tests | `Examples/ClaudeUIDemo/SnapshotTests` | One light and one dark reference image for every screen in `DemoScreen` | iPhone 15 Pro simulator, iOS 27.0 |
| UI tests | `Examples/ClaudeUIDemo/UITests` | Real taps and typing through the demo app, one file per feature | iPhone 15 Pro simulator, iOS 27.0 |
| Accessibility audit | `Examples/ClaudeUIDemo/UITests/AccessibilityAuditUITests.swift` | Apple's accessibility audit on every `DemoScreen`, light and dark | iPhone 15 Pro simulator, iOS 27.0 |

## One list of screens

[`Examples/ClaudeUIDemo/Shared/DemoScreen.swift`](../Examples/ClaudeUIDemo/Shared/DemoScreen.swift) names every screen the
demo can open directly. The same list drives three things:

- the demo app: `--screen <name>` opens that screen (for example `--screen settingsPrivacy --light`);
- the screenshot tests: one light and one dark image per case, plus the model picker, which only the package can
  construct;
- the accessibility audit: one audit per case, in both appearances, plus the model picker, opened from the composer.

To add a screen, add a case to `DemoScreen` and describe how to open it in `configureDemoScreen` (state) or
`DemoScreenView.view(for:state:)` (sheets and full-screen views) in
[`Demo/DemoScreens.swift`](../Examples/ClaudeUIDemo/Demo/DemoScreens.swift). Then record its
reference images and audit baseline as described below.

## Running the tests

Unit tests need no simulator:

```sh
swift test
```

Screenshot references and the accessibility baseline were recorded by CI with Xcode 27.0 (build 27A266a) and the
released iOS 27.0 simulator runtime, and are only valid on that configuration. Beta runtimes render Liquid Glass slightly
differently and fail a few screens by a fraction of a percent. With Xcode 27.0 selected, create the simulator once:

```sh
xcrun simctl create "iPhone 15 Pro (iOS 27)" "iPhone 15 Pro" com.apple.CoreSimulator.SimRuntime.iOS-27-0
```

Then, from `Examples/ClaudeUIDemo`:

```sh
xcodebuild test -project ClaudeUIDemo.xcodeproj -scheme ClaudeUIDemo \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro (iOS 27)' -only-testing:ClaudeUISnapshotTests
```

```sh
xcodebuild test -project ClaudeUIDemo.xcodeproj -scheme ClaudeUIDemo \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro (iOS 27)' -only-testing:ClaudeUIDemoUITests
```

## Screenshot tests

Each screen is rendered in a fresh, real window of the demo app, so Liquid Glass, materials and safe areas look the way
they do on device. Images are 1× (one pixel per point) 8-bit sRGB, which keeps the repository small while still catching
a one-point shift. A test fails when more than 0.1% of pixels differ visibly from the reference.

When a change is meant to alter how a screen looks:

1. Re-record with `TEST_RUNNER_SNAPSHOT_TESTING_RECORD=all` in front of the `xcodebuild test` command above.
2. Open every changed PNG under `SnapshotTests/__Snapshots__` and check it shows what you intended.
3. Commit the images together with the code change, and include before/after images in the pull request.

CI can re-record every reference on its own machine: Actions → CI → Run workflow → *Re-record screenshot references
and the accessibility baseline*. The recorded files are uploaded as artifacts. Images recorded with a different Xcode or
iOS version will not match.

Each capture waits 2 seconds before rendering, because Liquid Glass over a freshly shown card keeps adapting for about
1.5 seconds (measured).

Sheets (Settings and its pages, Devices, the model picker, the announcement) are presented over the session view with the
same plain `.sheet` presentation `ClaudeSessionView` uses, so they include the real sheet chrome.

## Accessibility audit

[`AccessibilityAuditBaseline.txt`](../Examples/ClaudeUIDemo/UITests/AccessibilityAuditBaseline.txt) lists every issue
the audit finds today, one per line: screen, appearance, issue and element. The test fails on any issue that is not in
the file, so a change cannot make accessibility worse. The file is also a to-do list: fix an issue, delete its line.

Most entries are fixed font sizes that ignore the system text size (Dynamic Type), small tap targets, and low contrast.
To regenerate the file after fixing issues, run the audit test with `TEST_RUNNER_ACCESSIBILITY_AUDIT_RECORD=1` and
review the diff before committing it.

## Evidence for a reviewed change

Attach exact test commands, the commit tested, configuration and result to the PR. Capture Xcode's version/build with `xcodebuild -version`; record the simulator model and runtime version/build as well. SDK version and simulator runtime version are different values. Use the same fixture, appearance, locale, text size, keyboard and accessibility settings when comparing screenshots.

For a private repository, choose **Actions → CI → Run workflow**, select the contribution branch and leave **Re-record screenshot references** off for verification. The simulator job must run, not be skipped. Re-recording produces candidate baselines for review; it is not a passing comparison run. CI currently uploads `.xcresult` bundles on failure; attach your local result bundle or link the successful job logs for a passing run.

Report failures and skipped suites explicitly. For widget registration or Home Screen changes, test a fresh simulator as well as the existing installation; screenshots of an in-app widget preview do not prove native gallery integration. A regression baseline detects changes to this project's output, not fidelity to the official app.
