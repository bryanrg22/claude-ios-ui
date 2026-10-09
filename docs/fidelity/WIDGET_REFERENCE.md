# System surface reference checklist

Widgets, Live Activities, and Dynamic Island are part of the requested interface scope. Twelve Home Screen gallery variants are now captured and inspected. Genuine WidgetKit extensions are implemented and both simulator gallery/route checks passed; final generic builds include each embedded extension. Dot compact/expanded system call UI is now captured; its internal framework is unproven. Lock Screen presentation and native implementation validation remain gaps.

The supplied dot call screenshots show an overlay inside the running app. They establish the in-app call panel, not a Home Screen widget or a Lock Screen Live Activity. Do not reuse that panel as evidence for a different surface.

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

For each installed app, inspect its widget gallery entry without adding or rearranging the user's existing widgets. Record the app/iOS versions, family, gallery title/description, available variants, appearance, and an inspected screenshot. Record any configuration sheet independently. Inspect Lock Screen/control-gallery entries separately; absence in one gallery does not prove absence in another.

For a Live Activity, record the actual system surface and transitions during an authorized reference session. Capture compact, minimal, expanded and Lock Screen views where available, plus connecting, active, muted, failed and ended states actually observed. Unsupported or unavailable states remain gaps, not invented replicas.

On October 8, 2026, phone control recovered after the earlier blocked Home editing attempts. The collector inspected nine ChatGPT gallery pages and three Claude gallery pages without adding, removing or rearranging widgets. All twelve screenshots were inspected; filenames below identify private references, not bundled assets.

| App / gallery title | Captured variants | Visible content and limits |
|---|---|---|
| ChatGPT / ChatGPT | Small, medium | Small Ask pill plus camera/voice circles; medium Ask ChatGPT pill plus camera/photos/microphone/voice controls |
| ChatGPT / ChatGPT shortcuts | Small, medium | Small two stacked shortcuts; medium four shortcuts in two columns. Actual configuration and installed tap behavior unverified |
| ChatGPT / Codex usage | Small, medium | Placeholder bars only. Loaded values, colors and reset presentation unknown |
| ChatGPT / Codex tasks | Medium, large, tall ninth variant | One-row, four-row and eight-row task previews with activity indicator. Tall variant's exact WidgetFamily is unconfirmed and unavailable in the current SDK; do not label it as a verified native family |
| Claude / Claude Quick Actions | Small, medium | Small Chat pill plus camera/voice; medium question pill plus camera/voice/code/final outlined action glyph |
| Claude / Code shortcuts | Small | Code pill plus new-session and search circles |

Portable private capture names: `chatgpt-widget-{chat-small,chat-medium,shortcuts-small,shortcuts-medium,codex-usage-loading,codex-usage-medium-placeholder,codex-tasks-medium,codex-tasks-large,codex-tasks-tall}.png` and `claude-widget-{quick-actions-small,quick-actions-medium,code-small}.png`.

The previews establish gallery layouts only. They do not prove Home Screen tint/clear modes, Lock Screen widgets, control-gallery entries, Live Activities, Dynamic Island, loaded usage data, configuration sheets or live interactions. The earlier October 8, 01:38 export predates this widget work.

## Contribution evidence

Keep raw references private. Commit only fictional demo renders, measured layout/timing notes and asset provenance. Every claimed surface needs its own reference and rendered verification; a generic WidgetKit sample, integration hook, or in-app overlay does not count as completed app fidelity.

## Dot system call reference and framework choice

Later October 8 captures establish a compact Dynamic Island (donut at leading edge, elapsed time at trailing edge) and its expanded call panel (donut, elapsed time, “Your dot”, mute and end controls). The selected mute screenshot uses a white circular control with a red slashed-microphone glyph; the other expanded reference shows the dark control. Connected in-app expanded/minimized call panels are separately captured. None of these images establishes the vendor's internal framework, and none captures the Lock Screen. Filenames containing `live-activity` are capture labels, not proof of ActivityKit.

Private originals: `chatgpt-dot-{call-connected-minimized,live-activity-compact,live-activity-expanded,call-mirroring-attempt}.png` plus five user-supplied clipboard captures archived in `dot-call-system/`. The latter preserve the original UUID filenames, decoded image dimensions and SHA-256 values in the manifest. The `2b7a494f` capture records selected mute; `03ed2516` records compact system UI; `7e9d221a` records expanded system UI; `6522bd67`/`6375dba3` record in-app connected panels. They contain private Home Screen/conversation content and are excluded from exports.

**Recommendation, not an implemented or tested result:** prototype an optional, explicitly started, local CallKit demo adapter if the target is the native system call surface. Keep the reusable SwiftUI presentation state independent. Do not create a custom ActivityKit lookalike and label it as the native call UI.

Apple says CallKit supplies the system calling interface while the app supplies communication transport. Its Live Activities team explicitly identifies CallKit as a separate way to display system UI in Dynamic Island; ActivityKit is the route for app-defined Dynamic Island UI. This supports CallKit as the candidate to investigate, but it does not identify ChatGPT's private implementation. [CallKit overview](https://developer.apple.com/documentation/callkit), [Apple Live Activities team Q&A, relevant framework distinction](https://developer.apple.com/news/?id=qpqf1gru), [current ActivityKit architecture](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities). The 2023 Q&A's older button guidance is not used as current interaction guidance.

A local demo can omit network transport and any audio capture/recording engine, supply fictional call metadata, send `CXStartCallAction` through a transaction, and report local connecting/connected/ended events. Apple itself demonstrates a simulated incoming call. That makes a backend-free prototype reasonable; successful no-microphone native rendering remains **unverified on the target device**. [Outgoing call lifecycle](https://developer.apple.com/documentation/callkit/making-and-receiving-voip-calls), [Apple's simulated-call demonstration](https://developer.apple.com/videos/play/wwdc2016/230/).

CallKit is not a passive screenshot renderer. Apple's flow configures an audio session and the system activates it before the provider's `didActivate` callback. Omitting an audio engine prevents our code from recording, but is not evidence that the system never activates an audio session, shows a microphone indicator, affects another audio session, or requires particular configuration. No guarantee of those behaviors or exact Dynamic Island geometry follows from the documentation. Verify start/connect/mute/unmute/end/reset and teardown on the target OS before enabling the optional demo. [Audio activation callback](https://developer.apple.com/documentation/callkit/cxproviderdelegate/provider(_:didactivate:)).

If a prototype is pursued, set `includesCallsInRecents = false`, allow one local demo call, use fictional generic handles, implement provider reset/end cleanup, and never fall back to telephone URLs or real contacts. Keep any microphone or transport implementation host-owned. Until device verification, ship pure local call-state previews as previews and leave native-system fidelity explicitly pending. [Provider configuration](https://developer.apple.com/documentation/callkit/cxproviderconfiguration).

Implemented and checked: offline connected-call and ordinary-view system-panel preview renderers. A genuine CallKit system demo remains a separate future spike; no actual ActivityKit call surface is claimed. The additional `chatgpt-dot-live-activity-expanded-muted.png` privately records selected mute.

Current verification: Claude native gallery passed 145.8s, installed small-widget links plus seven app routes 66.2s; ChatGPT native widget test passed 165.647s. These are simulator skeleton checks. The real-account source gallery session did not add or rearrange any user widget or verify its installed interactions. Tall Codex family, loaded usage, original configuration outcomes and alternate appearances remain gaps.
