# Versioning

This package follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html): `major.minor.patch`. Every release is a
Git tag with all three numbers (`0.1.0`, never `0.1`), because Swift Package Manager ignores tags that aren't full
semantic versions.

## What each number promises

| Bump | What may change | Examples |
|---|---|---|
| **patch** (`0.1.0` → `0.1.1`) | How screens look or behave. **No public API change at all.** | Spacing corrected to match the real app, an animation curve, a color, a bug in state handling, accessibility labels |
| **minor** (`0.1.0` → `0.2.0`) | **Additive** API only. Existing code keeps compiling. | A new screen and the state and actions that drive it, a new field on `SessionState` with a default value, a new theme property, a deprecation |
| **major** (`0.x` → `1.0`, `1.x` → `2.0`) | Anything that can break existing code. | Removing or renaming a type, action or field; changing what an existing action means; raising the minimum iOS version |

**Before 1.0.0, treat minor versions as potentially breaking.** The action and state shapes are still settling, and
Semantic Versioning explicitly allows anything to change in `0.x`. That is why the README recommends depending with
`.upToNextMinor(from:)` for now: you receive every patch (the visual fixes you want) and decide for yourself when to
take a minor. After 1.0.0, `from:` is the right rule.

## New actions and your `switch`

Your app receives UI events as a `switch` over `ClaudeAction` (and the nested action enums such as the settings and media
actions). Swift normally requires a `switch` to cover every case, so adding a case for a new screen would turn your
exhaustive `switch` into a compile error.

To make additions safe, every public action enum in this package is marked `@nonexhaustive`. The compiler then
refuses an exhaustive `switch` over it **when you first write it**, with the message "switch covers known cases, but
… may have additional unknown values", and asks for a fallback:

Either fallback works, and they behave differently on purpose:

```swift
switch action {
case .send(let text): // ...
case .stop: // ...
default: break            // quiet: handles every case you did not list, now and in future versions
}
```

```swift
switch action {
case .send(let text): // ...
case .stop: // ...
@unknown default: break   // strict: the compiler warns about every known case you skipped,
}                        // and later about each case a new version adds
```

With either in place, a case added by a later release never breaks your build: it is silently absorbed by `default`,
or reported as a warning by `@unknown default` so you can decide whether to handle it. That is what makes a new
action a **minor** release rather than a major one: the only error you can get is on day one, when you integrate,
never on an update.

## Deprecation before removal

Nothing public is removed without first being deprecated for at least one minor release:

1. The old symbol gets `@available(*, deprecated, message: "Use X instead")` pointing at its replacement. Your code
   keeps compiling with a warning.
2. The deprecation is listed under **Deprecated** in the CHANGELOG with the migration step.
3. The symbol is removed only in the next **major** release, and that release ships a migration guide under
   `docs/migration/`.

## How this is enforced

- Every pull request runs `swift package diagnose-api-breaking-changes` against the latest tag. If it reports a
  break, the pull request must carry the `breaking` label and the change must be documented, or it cannot merge.
- Screenshot tests catch unintended visual changes; intended ones are re-recorded in the same pull request and called
  out as `(visual)` in the CHANGELOG, so a patch release's visual changes are listed, not hidden.
- The CHANGELOG follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Each release's GitHub Release
  notes are that version's CHANGELOG section.

## Platform floor

The package requires iOS 26. Raising that minimum is a **major** change.
