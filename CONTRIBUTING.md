# Contributing UI changes

This is an unofficial interface skeleton. The app owns front-end presentation and local interaction state. Consumers supply their own backend. Keep contributions independently runnable with fictional sample data and no API keys or parent-repository dependencies.

## Establish the reference

Every visual change must record:

- Original app name, version, and build number, including how they were read.
- Capture date and time zone; iOS version/build and device model.
- Locale, appearance (light/dark/system), text size, accessibility settings, display zoom, and whether the software keyboard was visible.
- Exact starting screen and action sequence, including selected features, conversation state, and any account or plan restrictions.
- Before/after captures of the skeleton at the same viewport and configuration. Use a short recording or timed frames for motion.

Unknown values must stay unknown. The dimensions of a mirrored window do not establish the phone model or its native pixel resolution. A screenshot demonstrates one frame, not the full transition or font identity.

Use disposable, fictional content for any shareable reference. Do not submit personal chats, photos, filenames, account details, access tokens, or private recordings. Describe privately observed evidence in the baseline manifest without distributing it.

## Implement and verify

Prefer the matching native iOS menu, sheet, typography behavior, or material where the reference uses one. Match custom components only after inspecting the original. Document system-font and icon approximations explicitly; a similarly named SF Symbol is not evidence of an exact icon match.

Exercise empty, filled, disabled, selected, loading, error, completed, and dismissed states as applicable. Compare light and dark appearance, short and multiline text, keyboard presentation/dismissal, scrolling, menu dismissal, and repeat interactions. Inspect touch-down/pressed visuals and selection colors, not only idle screens. Do not change reference-app settings or send external messages merely to produce a test fixture.

Run the project's state tests and simulator interaction checks, and attach the commands/results to the contribution. Visual tests must use a pinned simulator/iOS configuration. A snapshot regression passing only proves consistency with the committed baseline, not fidelity to the real app. Keep unsupported states listed rather than disguising them with inert buttons or claims of completed backend work.

## Assets and attribution

Record every imported font, logo, symbol, and media asset in the project's asset provenance file: source URL, version, license/permission, changes, and whether redistribution is allowed. Preserve original notices. System-provided fonts and SF Symbols should be resolved through Apple APIs, not extracted and redistributed. Brand ownership and third-party asset licenses remain separate from the code license. Do not select a blanket repository license that purports to relicense those assets. Clearly identify the project as unofficial and avoid claims of endorsement.

## Suggested pull request body

```text
Reference: app/version/build; captured YYYY-MM-DD; iOS/device; locale/theme/text size
Change: screen and the visible behavior before/after
Interactions: starting state -> action -> resulting state, including reversal/dismissal
Evidence: sanitized screenshots/recording or private reference IDs
Validation: commands, simulator configuration, and results
Known differences: typography/icons/motion/screens not yet matched
Assets: new source and redistribution permissions, or no asset changes
```
