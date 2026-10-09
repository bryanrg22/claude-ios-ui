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
4. **Run the tests** described in [TESTING.md](TESTING.md). For an intended visual change, re-record the affected
   screenshot references and look at every changed image.
5. **Open a pull request.** The template asks for a before/after table: the real app, the recreation before, and the
   recreation after. CI runs every test suite, and the maintainer reviews and merges.

## Evidence

A comparison is only meaningful like for like. Capture the real app and the recreation with the same:

- device size (the references use an iPhone 15 Pro) and iOS version;
- appearance (light or dark) and text size;
- starting screen and steps, including what you tapped.

Note the Claude app version from the **ⓘ menu in Settings**. A single screenshot shows one frame; for animations and
transitions, attach a short screen recording.

**Remove personal information** before uploading: names, email addresses, conversation text, photos and file names.
Use a fresh conversation with neutral content when you can. Upload reference captures to the issue or pull request;
don't commit screenshots of the real app to the repository.

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

## Assets and licensing

Code contributions are accepted under the [MIT License](LICENSE). Never extract fonts, icons, illustrations or other
files from the app's install package. Use system fonts and SF Symbols through Apple's APIs, or original artwork you have the right
to share. Record every new font, image or media file in [THIRD_PARTY.md](THIRD_PARTY.md) with its source, license and whether it
may be redistributed.

This project is unofficial and must not suggest endorsement by Anthropic.
