# Changelog

All notable changes to this project are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). Until 1.0.0, minor
versions may change the public API; see each entry.

## [Unreleased]

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

[Unreleased]: https://github.com/bryanrg22/claude-ios-ui/compare/0.1.0...HEAD
[0.1.0]: https://github.com/bryanrg22/claude-ios-ui/releases/tag/0.1.0
