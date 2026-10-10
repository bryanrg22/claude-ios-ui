# Changelog

All notable changes to this project are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html) as described in `docs/VERSIONING.md`. Until 1.0.0,
minor versions may change the public API; see each entry. Entries tagged `(visual)` change how a screen looks, and
each release notes how many screenshot references were re-recorded.

## [Unreleased]

## [0.2.0] - 2026-10-10

Screenshot references re-recorded: 1 screen (light and dark).

### Changed

- **Breaking for exhaustive switches.** Every public action enum is now `@nonexhaustive`. An exhaustive `switch`
  over one of them no longer compiles; add `@unknown default` (or `default`). From now on a case added by a later
  release is a warning at that fallback rather than a build error. See `docs/VERSIONING.md`.
- The README now recommends `.upToNextMinor(from:)` while the package is 0.x, so updates deliver patches only.
- (visual) The Notifications settings rows now follow the system text size (Dynamic Type). At the default
  size the subtitle is 13 pt, where it was 13.3 pt.
- The fidelity records under `docs/fidelity` now cover the Claude app only.

### Added

- `docs/VERSIONING.md` and `docs/UPDATING.md`: what each version number promises, and how to update, pin, roll back
  and automate updates in an app.
- Xcode previews for every catalogued screen in light and dark, in the demo app
  (`Examples/ClaudeUIDemo/Demo/DemoScreenPreviews.swift`).
- CI compares the public API with the latest release on every pull request; API changes need the `breaking` label.
- Pushing a version tag publishes the GitHub Release from this file, and version tags can no longer be moved or
  deleted. Dependabot keeps the workflow actions and package dependencies current.

### Fixed

- UI tests wait for keyboard focus before typing, which removes an intermittent failure.

## [0.1.0] - 2026-10-09

First release.

### Added

- `ClaudeUI`: SwiftUI views and presentation state for the Claude iPhone app's
  interface: chat and composer, model and effort pickers, dictation, voice mode,
  camera, photos and video, Markdown with syntax-highlighted code, Settings and
  its pages, Claude Code (sessions, environments, repositories, connectors,
  routines), Dispatch, Devices, Projects and Artifacts. Light and dark
  appearance, Liquid Glass materials, no backend.
- `ClaudeWidgets`: Home Screen widget views with typed deep links.
- A demo app (`Examples/ClaudeUIDemo`) with fictional data, a WidgetKit
  extension and a `--screen <name>` launch argument for every catalogued screen.
- Tests: 127 unit tests, screenshot references for 35 screens in both appearances,
  36 UI tests and an accessibility audit with a recorded baseline, all run in CI.
- Documentation: integration guide, per-feature guides and fidelity records.

### Known limitations

- The Customize page does not exist yet; About, Account, Add account, Gift,
  Permissions and Voice settings pages are placeholders.
- Populated Projects states, the speaking waveform, Lock Screen widgets, Live
  Activities and Dynamic Island are not built.
- Text uses fixed sizes and does not follow the system text-size setting.

See the issue tracker for the current list.

[Unreleased]: https://github.com/bryanrg22/claude-ios-ui/compare/0.2.0...HEAD
[0.2.0]: https://github.com/bryanrg22/claude-ios-ui/releases/tag/0.2.0
[0.1.0]: https://github.com/bryanrg22/claude-ios-ui/releases/tag/0.1.0
