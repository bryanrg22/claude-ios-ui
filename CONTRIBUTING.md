# Contributing

Thanks for helping. This project recreates the Claude iPhone app's interface, so most contributions are one of three
things: making a screen match the real app more closely, adding a screen the real app has gained, or fixing a bug in
the package. All three follow the same path.

## How a change gets in

1. **Find or open an issue.** Use the issue forms: *Screen doesn't match the app*, *The app changed or a screen is
   missing*, or *Bug in the package or demo*. They ask for exactly what a reviewer needs. Issues labelled
   `good first issue` are a good place to start.
2. **Capture the reference.** Screenshot or record the real app (see [Evidence](#evidence) below).
3. **Make the change** in `Sources/ClaudeUI`. Use the demo's `--screen <name>` launch argument to open the screen
   directly while you work.
4. **Run the tests** described in [TESTING.md](docs/TESTING.md). For an intended visual change, re-record the affected
   screenshot references and look at every changed image.
5. **Open a pull request.** The template asks for a before/after table: the real app, the recreation before, and the
   recreation after. The maintainer reviews the evidence and test results before approving and merging. Simulator suites need a manual Actions run while the repository is private; a green checks-only run is not full UI verification.

## Evidence

A comparison is only meaningful like for like. Capture the real app and the recreation with the same:

- device size and iOS version (the screenshot-test baseline uses iPhone 15 Pro; the physical reference may differ, so record both);
- appearance (light or dark) and text size;
- starting screen and steps, including what you tapped.

Note the Claude app version from the **ⓘ menu in Settings**. A single screenshot shows one frame; for animations and
transitions, attach a short screen recording.

**Remove personal information** before uploading: names, email addresses, conversation text, photos and file names.
Use a fresh conversation with neutral content when you can. Upload reference captures to the issue or pull request;
don't commit screenshots of the real app to the repository.

## What to include in your pull request

- The issue number and the specific screen or interaction that changed.
- Real-app reference, recreation before, and recreation after, with light/dark comparisons when the affected screen supports both.
- Device model and viewport, iOS version **and build**, Xcode version **and build**, source app version, locale, text size, keyboard state and relevant accessibility settings. Write **unknown** for unverified reference metadata.
- For animation changes: short before/after recordings, reference recording, frame rate, measured start/end, duration/easing and any remaining difference. Do not substitute an idle screenshot for motion evidence.
- Commands and results for the relevant tests, plus a CI run link and an `.xcresult` artifact when available. State what was not run and why.
- A regression check for the existing path: opening, interacting, dismissing and returning to the conversation. Include long text, keyboard and selected/disabled/error states when they are affected.

Do not re-record snapshots just to turn a failure green. First establish whether the code, reference environment or intended design changed. Snapshot updates belong in the same PR as the justified change. Unrelated changes and a new backend belong in separate work.

The [review guide](docs/REVIEW_GUIDE.md) is the maintainer's acceptance checklist. Its evidence requirements are reviewed by a human; a checked PR box does not prove that a test ran.

## Implementation guidelines

- **Prefer native components.** Where the real app uses a system menu, sheet, material or font behavior, use the same
  SwiftUI or UIKit component rather than a custom imitation.
- **Say what's approximate.** A similar-looking SF Symbol or system font is an approximation, not a match. Note it in
  the pull request and in the relevant guide under [`docs/features`](docs/features).
- **Cover every state.** Check empty, filled, disabled, selected, loading, error and dismissed states as they apply, in
  light and dark, with short and long text, and with the keyboard shown and hidden.
- **Keep the package backend-free.** No networking, API keys or device access in `Sources`. Anything that would need a
  server or the system becomes a typed action for the host app. Sample data belongs in the demo
  (`Examples/ClaudeUIDemo/Demo`), not in the package.
- **Don't fake unfinished work.** If a destination isn't built yet, leave its "not built yet" notice in place rather than
  adding a button that silently does nothing.
- **New screens** get a case in [`Shared/DemoScreen.swift`](Examples/ClaudeUIDemo/Shared/DemoScreen.swift), which
  gives them screenshot references and an accessibility audit automatically.
- **Code style** is enforced by `swift format lint --strict`. Run `swift format format --in-place --recursive .`
  before committing.

## Public API, versions and deprecation

Apps depend on this package's public API: the state types, the action enums and the view initializers. CI compares
that API with the latest release on every pull request. The rules, with the reasoning, are in
[docs/VERSIONING.md](docs/VERSIONING.md); the short version:

- A visual or behavioral fix with no public API change is a **patch**. Tag such CHANGELOG entries `(visual)`.
- New screens, actions, state fields (with defaults) and theme properties are **minor**. New action enums must be
  marked `@nonexhaustive` like the existing ones.
- Never remove or rename a public symbol directly. Mark it `@available(*, deprecated, message: "Use X instead")`,
  list it under **Deprecated** in the CHANGELOG, and leave it for at least one minor release. Removal happens only
  in a major release, with a migration guide under `docs/migration/`.
- A pull request whose API check fails needs the `breaking` label and a CHANGELOG entry, or a change of approach.

## Assets and licensing

Code contributions are accepted under the [MIT License](LICENSE). Never extract fonts, icons, illustrations or other
files from the app's install package. Use system fonts and SF Symbols through Apple's APIs, or original artwork you have the right
to share. Record every new font, image or media file in [THIRD_PARTY.md](THIRD_PARTY_NOTICES.md) with its source, license and whether it
may be redistributed.

This project is unofficial and must not suggest endorsement by Anthropic.
