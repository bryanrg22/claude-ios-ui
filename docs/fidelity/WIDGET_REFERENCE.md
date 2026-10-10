# System surface reference checklist

Widgets, Live Activities, and Dynamic Island are part of the requested interface scope. Three Home Screen gallery variants are now captured and inspected. A genuine WidgetKit extension is implemented and the simulator gallery/route checks passed; the final generic build includes the embedded extension. Lock Screen presentation, Live Activities and Dynamic Island remain gaps.

## Native implementation standard

Use a separate WidgetKit extension for observed widgets. Supply sample timeline entries for the gallery and injected presentation data for the host. Use `widgetURL`/`Link` for navigation and App Intents for observed interactive controls. A widget tap can open the local skeleton destination without executing a remote task or starting a real call.

Use ActivityKit attributes/content state and `ActivityConfiguration` for an observed Live Activity, including its distinct compact, minimal, expanded, and Lock Screen layouts. Keep model calls, audio sessions, remote connections, push delivery, and authentication outside the UI package. Preview each observed content state without requiring a server.

Widget families and dimensions vary by device. Follow native content margins and the family supplied by WidgetKit; do not infer support for every family from one screenshot. Check light/dark, full color, tinted/clear where available, disabled/loading/error state, and tap destination separately.

Primary references:

- [Creating a WidgetKit extension](https://developer.apple.com/documentation/WidgetKit/Creating-a-Widget-Extension)
- [Widget families](https://developer.apple.com/documentation/widgetkit/widgetfamily/)
- [WidgetKit strategy and system appearances](https://developer.apple.com/documentation/widgetkit/developing-a-widgetkit-strategy/)
- [Previewing Live Activity content states](https://developer.apple.com/documentation/widgetkit/preview%28_%3Aas%3Ausing%3Awidget%3Acontentstates%3A%29)
- [Displaying live data with ActivityKit](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)

## Required empirical capture

Inspect the app's widget gallery entry without adding or rearranging the user's existing widgets. Record the app/iOS versions, family, gallery title/description, available variants, appearance, and an inspected screenshot. Record any configuration sheet independently. Inspect Lock Screen/control-gallery entries separately; absence in one gallery does not prove absence in another.

For a Live Activity, record the actual system surface and transitions during an authorized reference session. Capture compact, minimal, expanded and Lock Screen views where available, plus connecting, active, muted, failed and ended states actually observed. Unsupported or unavailable states remain gaps, not invented replicas.

On October 8, 2026, phone control recovered after the earlier blocked Home editing attempts. The collector inspected three gallery pages without adding, removing or rearranging widgets. All three screenshots were inspected; filenames below identify private references, not bundled assets.

| Gallery title | Captured variants | Visible content and limits |
|---|---|---|
| Claude Quick Actions | Small, medium | Small Chat pill plus camera/voice; medium question pill plus camera/voice/code/final outlined action glyph |
| Code shortcuts | Small | Code pill plus new-session and search circles |

Portable private capture names: `claude-widget-{quick-actions-small,quick-actions-medium,code-small}.png`.

The previews establish gallery layouts only. They do not prove Home Screen tint/clear modes, Lock Screen widgets, control-gallery entries, Live Activities, Dynamic Island, configuration sheets or live interactions. The earlier October 8, 01:38 export predates this widget work.

## Contribution evidence

Keep raw references private. Commit only fictional demo renders, measured layout/timing notes and asset provenance. Every claimed surface needs its own reference and rendered verification; a generic WidgetKit sample, integration hook, or in-app overlay does not count as completed app fidelity.

Current verification: the native gallery passed 145.8s, installed small-widget links plus seven app routes 66.2s. These are simulator skeleton checks. The real-account source gallery session did not add or rearrange any user widget or verify its installed interactions. Original configuration outcomes and alternate appearances remain gaps.
