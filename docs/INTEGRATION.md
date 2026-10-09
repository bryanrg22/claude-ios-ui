# Integration guide

How to put `ClaudeUI` into your own app and connect it to your backend. The package draws the interface and keeps presentation state; your app owns networking, persistence, authentication and device access.

## Getting started

The package declares its dependencies with minimum versions (`from:`), so your app can resolve a version that also satisfies its other packages. The committed `Package.resolved` records the exact versions this repository is tested with; your own app's `Package.resolved` decides what it ships.

Add this directory (or your published repository URL) as a Swift package dependency and import `ClaudeUI`. Own the state in your application and consume typed UI intents:

```swift
@State private var session = SessionState()

var body: some View {
    ClaudeSessionView(state: $session) { action in
        session.reduce(action)
        // Route .send, .stop, .startDictation, .share, etc. to your adapter.
        // Capture let requestID = session.responseID after Send or Retry.
        // Deliver chunks with session.appendResponse(chunk, responseID: requestID)
        // and session.finishResponse(responseID: requestID).
        // Old request tokens are rejected, including after a new send.
    }
}
```

Native Settings uses injected `SessionState.settings` account/profile data and typed `.settings(...)` actions. Profile edits are reversible drafts; saving requires a matching host acknowledgement. Notification and break-reminder presentation preferences are host-persistable local values. Privacy consent and Usage balances remain host-owned: switches emit requests without changing account truth. Billing reproduces the captured website-origin native notice; shared links display injected read-only snapshots. Code appearance preferences are serializable local UI values. Capabilities, Memory files, and Settings connector permissions use host-owned data and typed requests; memory deletion needs a matching host acknowledgement. Connector browsing uses injected cards, ranking and categories with local search/filter state; custom connector name/HTTPS URL drafts emit a host request and are discarded on cancel. All tools policies remain host-owned. Photo changes, logout, quiet-day details, and unobserved subpages remain host intents. See [Settings coverage](features/SETTINGS.md). `--announcement` presents the observed feature-announcement still with working dismissal; its motion has not been reconstructed.

Feedback submission intents include sentiment, comment, and issue category; cancellation never emits a submission.

Voice intents include entry/exit, microphone/output toggles, voice/language selection, and `.voiceFeedback(Bool)` from the exit summary. Voice entry preserves the conversation and unsent draft; exit restores the composer. No audio session is created.

`SessionState.devices` contains host-injected device rows and account profile state. It defaults to no devices; only the demo fixture supplies a Connected desktop. `.devices(.openManage)` creates an account request token. Deliver profile data with `devices.finishAccountLoad(profile, requestID:)` or failure with `failAccountLoad`; replaced or dismissed request tokens are ignored. Profile edits are local state, and logout, API keys, photo changes, links, account tabs, and organization copy are typed host intents. The demo copies only its fictional organization ID and performs no account operation.

`SessionState.dispatch` supplies connection status, timestamped messages, draft, and token-guarded loading. `.openDispatch` presents the observed route and creates `dispatch.loadID`; the host delivers messages with `finishLoading(_:requestID:)`. `.dispatch(.submit(text))` and `.dispatch(.attach)` are integration hooks. They intentionally leave the draft and messages intact until a host implements their outcomes. The demo injects an Online fixture and welcome text; it never connects to a desktop or sends a task. Unobserved attachment menus, sent-task states, and error visuals remain gaps.

`SessionState.code` accepts `CodeSession` and `CodeDevice` rows and applies local status filtering. `.openCode` switches to the observed list without changing the chat. `.code(...)` carries session/device/search hooks and opens the observed New session and remote-control setup views; no task starts. `CodeDraftState` keeps injected repositories, environments, branches, local model/effort and connector permissions separate from normal chat. Connector logos in the synthetic fixture remain SF Symbol stand-ins. `.code(.editor(...))` exposes typed host intents for task submission, media, environment creation and service connections. The clock opens the observed Routines surface. `.code(.routines(...))` carries local form edits, schedule UI choices, and host-only draft/create/configuration intents. No cron, webhook, or scheduler is implemented. Cancel clears the unsaved routine; backing between description and manual setup preserves it. Other repeat-specific fields and routine detail/results are not captured.

The package renders app-owned `SessionState` and sends `ClaudeAction` intents. The reducer supports drafts, streaming, stop, dictation recording/paused/cancel/commit, attachments, models, effort, approval mode, device choice, new sessions, reversible message editing, and inline voice controls. There are no imports of an automation project or backend SDK.

Use `ClaudeTypography(serifName: "YourLicensedFont")` to replace the bundled Newsreader approximation. All package resources are located via `Bundle.module`.

## Offline camera presentation

`ClaudeCameraView(onCancel:onCapture:preview:)` accepts any SwiftUI preview supplied by the host. `CameraCapture` contains mode, zoom, and front/back selection; it contains no media bytes. The demo uses an original synthetic scene and attaches a named sample on capture. Photo layout follows the supplied camera reference; video recording and flash/flip transitions are local demo behavior, with exact production motion still unverified. No uncaptured photo review screen is invented.

For editing, the view emits `.beginEditing(messageID)` and `.cancelEditing`; committing emits `.send(text)`. `visibleMessages` hides future content without changing `messages` until commit. Hosts may capture `editingMessageID` before reducing Send to route an edit request to their own backend.

## Dictation waveform contract

The host may update `session.dictationLevels` with normalized sample amplitudes. The UI retains the newest 256 samples, clamps finite values to 0…1, and maps NaN/infinity to silence. Bars remain inside a 24pt maximum height within the 36pt controls row; silence preserves the observed 2.6pt dots at 6pt spacing. The 24pt audible cap and 80ms interpolation are **provisional design bounds**, not measurements of Claude's speaking animation. Supply recorded mobile evidence before treating them as a fidelity target. Reduced Motion disables interpolation.

Silent Stop restores the prior draft and normal composer, matching the observed mobile behavior. Stop with a nonempty transcript retains an unverified paused preview state; no microphone capture/transcription is implemented.

`SessionState.projects` and `.openProjects` expose the observed Projects empty state and feature setup. `.projects(ProjectAction)` carries local edits, icon/context choices and a host-only creation request. No project or Drive connection is created automatically; hosts can acknowledge accepted creation with `state.projects.acknowledgeCreated(_:)`. See [Projects reference limits](features/PROJECTS.md) for unobserved populated states, icon approximations and validation details.

`SessionState.artifacts` and `.openArtifacts` present the captured Artifacts list and document viewer. Inject `ClaudeArtifact` rows with optional `ArtifactDocument` content, or provide a custom document renderer to `ClaudeArtifactsView`. Local filters/search/collapse work without services. `.artifacts(...)` emits typed share, comment, tab and history intents; no real document or account is modified. Unobserved non-document viewers remain host responsibilities. See [Artifacts reference coverage](features/ARTIFACTS.md).

The independent `ClaudeWidgets` product provides the three captured Home Screen layouts and typed deep links. The demo includes a real embedded WidgetKit extension; build/install the app, then add “Claude UI Demo” from the system widget gallery. Launch with `--widgets` for an interactive in-app preview. See [widget scope, routing and validation](features/WIDGETS.md).

Assistant responses and artifact paragraphs render through `ClaudeMarkdownView` and the pinned official Swift Markdown AST parser. Inject Markdown, a theme, optional image/unsupported-content views, and typed host callbacks. Initial SwiftPM resolution downloads the parser and the pinned HighlighterSwift syntax-coloring dependency; rendering itself is offline. Code blocks use native attributed token colors, with the existing host override available. `--markdown` opens a synthetic formatting fixture. See [supported syntax, host contracts and unverified styling](features/MARKDOWN.md).

Inject photo metadata through `SessionState.media` and pixels through `ClaudeSessionView(mediaContent:)`. The Recent selection, draft thumbnails, sent-image bubble, file-name context menu, and full-screen viewer are local UI; Photos/Edit/Share emit host intents. See [media contracts and unobserved states](features/MEDIA.md).

Video descriptors (`ClaudeMedia(kind: .video)`) use the captured file-card/large-sheet route. Supply `.videoViewer` content and handle Download/playback lifecycle intents in the host. `--video` demonstrates a bundled original silent clip, with no upload or external media access. Details and provenance are in [media contracts](features/MEDIA.md).
