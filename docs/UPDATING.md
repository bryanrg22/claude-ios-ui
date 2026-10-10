# Updating the package in your app

The package is a normal Swift Package Manager dependency, so updates use the standard Swift tooling. Your project
records the exact version it uses in its own `Package.resolved`; **nothing changes until you ask for an update.**

## See what an update would bring

Each release's notes are its section of [CHANGELOG.md](../CHANGELOG.md). Entries tagged `(visual)` describe
screen changes; entries under **Added** that mention a new action tell you a `switch` fallback will fire (see
[VERSIONING.md](VERSIONING.md)). To preview without changing anything:

```bash
swift package update --dry-run
```

## Update

**Xcode:** File → Packages → Update to Latest Package Versions. (This updates every package in the project.)

**Command line**, for this package only:

```bash
swift package update claude-ios-ui
```

Then build. If a new version added an action, your `@unknown default` fallback covers it until you handle it; the
CHANGELOG entry says what the new action is for.

Which versions an update can reach is set by your dependency rule:

| Rule in `Package.swift` | Updates you receive | Recommended |
|---|---|---|
| `.upToNextMinor(from: "0.1.0")` | Patches only: `0.1.1`, `0.1.2`, … | **Yes, while the package is 0.x** |
| `from: "0.1.0"` | Everything below `1.0.0`, including `0.2.0` | After 1.0.0 (as `from: "1.0.0"`) |
| `exact: "0.1.0"` | Nothing | Only to freeze a release temporarily |

To move to a new minor on purpose, change the rule (for example to `.upToNextMinor(from: "0.2.0")`) and update.

## Pin a version

Your `Package.resolved` already pins the exact version your app builds with. Commit it. (For an Xcode project it
lives at `YourApp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.) To make CI refuse to
drift from it:

```bash
swift build --only-use-versions-from-resolved-file
```

```bash
xcodebuild -onlyUsePackageVersionsFromResolvedFile ...
```

## Roll back

```bash
swift package resolve claude-ios-ui --version 0.1.0
```

Or restore the previous `Package.resolved` from Git. In Xcode, set the package's rule to **Exact** with the version
you want, then File → Packages → Resolve Package Versions.

## Get update pull requests automatically

GitHub's Dependabot supports Swift packages, including Xcode projects. Add this file to your app's repository as
`.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: "swift"
    directory: "/"
    schedule:
      interval: "weekly"
```

Dependabot respects your dependency rule, so with `.upToNextMinor` it opens a pull request for each patch release and
leaves minors for you to take deliberately. [Renovate](https://docs.renovatebot.com/modules/manager/swift/) works
the same way for `Package.swift` manifests.

## If you changed the package itself

If you edited the package's source to restyle it, the sanctioned path is Apple's local-package override: add your
edited copy to the project as a local package. It overrides the dependency with the same name while you work. When
your change (or an equivalent one) ships in a release, remove the local package and update the dependency to that
version. See [Editing a package dependency as a local package](https://developer.apple.com/documentation/xcode/editing-a-package-dependency-as-a-local-package).

Better still, send the change back as a pull request; what you needed, someone else needs too.
