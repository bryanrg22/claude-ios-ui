# Reviewing a contribution

A passing test run protects the skeleton's behavior. Reference evidence establishes whether its appearance moved closer to the real Claude app. Review both before approval.

## Acceptance checklist

1. **Confirm scope.** The PR names one screen/flow, links an issue where relevant and describes the resulting behavior. Keep backend, credentials, device access and service integration outside the UI package.
2. **Compare evidence.** Check real app, before and after side by side. Match device/viewport, appearance, content and text size. Record both environments if the reference phone differs from the simulator. Unknown metadata stays unknown.
3. **Review state and motion.** Verify the affected empty/filled, selected/disabled, keyboard, loading/error and dismissal/return states. For motion, watch the recordings and check measured timing; a static snapshot cannot establish waveform dynamics, easing or transition duration.
4. **Check validation.** Unit tests, format, project sync and the iOS 26 SDK build must pass. Visual changes also need relevant UI flows, light/dark screenshot comparisons and an accessibility regression check. New screens belong in `DemoScreen`. Native widgets/system state require a fresh-simulator check in addition to a reused installation.
5. **Inspect baselines.** Open every changed image and explain each intentional difference. Keep the recorded device/runtime fixed. A changed Xcode/runtime needs an explicit baseline migration, not silent tolerance increases. A record-mode run is not a successful comparison run.
6. **Check remaining gaps.** Document approximations, skipped cases and outstanding TODOs. Existing accessibility baseline entries are known debt, not proof of full accessibility. Do not claim complete parity from CI.
7. **Approve and merge.** Resolve review comments and confirm results apply to the latest commit. Request changes for missing evidence or regressions; a maintainer approves and merges when the checklist is satisfied.

## GitHub workflow

Contributors open a PR using the provided template. Reviewers can use **Files changed** to comment on specific lines, then **Review changes → Approve** or **Request changes**. The checklist is a review policy; repository rules and required checks enforce merge permissions separately.

Both repositories currently run simulator suites automatically only when public. While private, use **Actions → CI → Run workflow**, select the PR branch, and leave reference recording disabled. Confirm the **Screenshot and UI tests (iOS 27)** job ran successfully; a skipped simulator job does not satisfy visual validation. See [Testing](../TESTING.md) for commands and the pinned baseline.

The issue forms and PR template follow [GitHub's contribution-template workflow](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests). GitHub validates required issue-form fields only for public repositories, so reviewers must still check completeness while these repositories are private.

## Suggested evidence layout

| Artifact | What the reviewer should see |
|---|---|
| Reference image/video | The real app's versioned state, using neutral content |
| Before image/video | The same state in the PR's base commit |
| After image/video | The same state in the contribution commit |
| Test evidence | Commands, tested commit, configuration, CI logs and available result bundles |
| Remaining differences | Specific approximations or states that remain TODO |

Official-app captures are evidence attachments, not bundled assets. Commit only synthetic demo snapshots and assets with redistribution provenance. Do not upload personal conversation content, account details, credentials or private photos.
