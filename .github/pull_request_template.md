## What changed

<!-- Link the issue, e.g. Fixes #123. Explain the trigger and resulting behavior. -->

## Visual evidence

<!-- Required for visual changes. Use neutral content. Upload screenshots into the cells; link recordings below for motion. Include both appearances, or explain why one does not apply. -->

| Appearance | Real-app reference | Recreation before | Recreation after |
|---|---|---|---|
| Light | | | |
| Dark | | | |

**Reference app version:**
**Reference device / iOS version and build:**
**Demo device / iOS version and build:**
**Xcode version and build:**
**Locale / text size / keyboard / accessibility settings:**
<!-- Write unknown for metadata you cannot verify. -->

**Motion recordings and measurements:** <!-- Reference, before, after; FPS, duration/easing. Or N/A. -->

## Validation

| Check | Command or CI link | Result |
|---|---|---|
| Unit tests | | |
| Affected UI flow and return/dismiss regression | | |
| Screenshot comparisons, light and dark | | |
| Accessibility regression | | |

**Not run / skipped and why:**
**Fresh simulator check:** <!-- Required for changes involving widgets, installation or system state; otherwise N/A. -->
**Known differences / remaining TODOs:**

## Review checklist

- [ ] Relevant tests passed; failures/skips and the tested commit are recorded above
- [ ] Visual evidence includes reference, before and after; motion evidence is included where needed
- [ ] Snapshot changes are intentional, individually reviewed and explained; no baseline was updated solely to hide a failure
- [ ] New screens have `DemoScreen` coverage; relevant fidelity/feature notes are updated
- [ ] The package stays UI-only; new assets have provenance and uploads contain no personal information

<!-- Maintainer: use docs/REVIEW_GUIDE.md. Green CI can skip simulator suites while private; run CI manually with recording disabled before approving UI changes. -->
