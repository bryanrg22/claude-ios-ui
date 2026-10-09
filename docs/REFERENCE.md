# Reference coverage — October 7, 2026

Source: live iPhone Mirroring observations of the installed Claude app, version 1.261002.20 (37091698851). Captured window 820×1796; phone content approximately x17,y76,width786,height1704, corresponding to 393×852 points. Status-bar content is owned by iOS; do not reproduce a fake status bar in the UI.

Raw captures include private account/conversation data and remain outside this distributable directory. Names, emails, chat history, and photo previews here are synthetic.

| State / action | Observed reference | Implementation / limitation |
|---|---|---|
| Empty home | Dark #141414, orange brand mark, serif greeting, two glass header circles | Implemented; Newsreader is a licensed substitute, exact reference font unconfirmed |
| Empty composer | Placeholder, plus, model/effort pill, microphone, white voice button | Implemented |
| Typing | Voice button becomes orange arrow; focused inset shrinks from 16 to 8pt | Implemented |
| Multiline draft | Height grows until approximately 415pt total with hardware keyboard; extra text scrolls | 16-line native text field with intrinsic-height preservation; simulator max approximately 419pt versus observed 415pt, so final tuning remains |
| Send | Right-aligned gray user bubble; stop square replaces send; assistant serif response | Implemented with synthetic local streaming |
| Stop | Stop intent should halt response | Reducer tested; exact live stopped layout not yet compared |
| Copy | Copy icon changes to check; top glass Message copied toast | Implemented; transient timing approximate |
| Read aloud | Play changes to outlined pause | UI toggle implemented; no audio engine |
| Positive/negative feedback | Half sheet, text area, cancel and submit; negative issue picker | Implemented with synthetic disclosure; no network submission |
| User long press | Copy, Send to, Select text, Edit; timestamp header | Native context menu; timestamp header omitted; Send to/Select text destinations incomplete. Edit uses the verified in-conversation composer and reversible state |
| Assistant long press | Repeated observation produced no menu | No added assistant context menu |
| Dictation | Cancel circle, dotted silent waveform, stop square, orange arrow | Verified silent dots retained; host-level waveform API added with provisional 24pt cap and 80ms interpolation; actual mobile speaking amplitude/motion remain unmeasured |
| Cancel dictation | Must preserve draft | State tested; exact animated transition unmeasured |
| Stop dictation | Silent Stop returns idle | Silent Stop verified and implemented; nonempty-transcript pause remains an unverified host-preview state |
| Model sheet | Fable5.1, Opus5.5, Sonnet5.5, Haiku5.5; effort drill-in | Implemented as offline reference labels |
| Effort | Low, Medium recommended, High, Extra, Max usage warning | Implemented; orange usage warning implemented |
| Attachments | Camera/photo strip, files/project, permission/devices | Main sheet implemented; photos synthetic; Camera uses captured full-screen reference; photo/file library pickers remain placeholders |
| Permission | Manual and automatic, descriptions and check | Implemented, changes local state only |
| Attachment device selector | Desktop row, last seen, default badge, check and explanation | Earlier synthetic selector retained separately from header Devices |
| Header Devices | Half-height sheet, display-only connected desktop, Manage devices row | Implemented injected rows; no discovery or connection operation |
| Manage devices | Account tabs, profile fields/instructions, logout, disabled delete, organization ID | Observed Account content implemented with fictional values and typed host intents; other tabs not reconstructed |
| Dispatch | Online badge, subtle grid/warm bottom gradient, timestamp/wavy separators, serif welcome, glass task composer | Implemented injected state; send and attachment results not observed, so callbacks only |
| Sidebar | Projects, Code, Artifacts, Scheduled, Dispatch; pinned/recent; account/new | Implemented with synthetic content; Dispatch and Code/Routines observed, other non-chat destinations remain incomplete |
| Settings | Account group, gift, account links, app group | Main screen implemented; most deeper pages placeholders |
| Theme | User requested light/dark/system | Implemented switching; dark and light home observed; inline Light/Dark/System thumbnails implemented from the Settings reference |
| Voice conversation | Inline transcript, gear header, thumbs-only response actions, large mic above plus/model/output/exit row | Implemented from the silent live session; actual speaking visuals remain unknown |
| Voice settings | Clara/Suave cards, selected Suave centered, model row, Language Beta | Implemented; only observed language shown; no voice playback |
| Exit voice | Ordinary composer returns; glass summary with elapsed duration, thumbs and dismiss | Implemented local duration and feedback; exact auto-dismiss timing and rating consequences unverified |
| Animations | Native glass, presentation and dismissal | Native sheet/menu interaction; exact timing not yet measured |

## Validation

State tests cover voice entry/exit preservation and incompatible-mode guards, empty/reentrant sends, stop ignoring late chunks, draft preservation on cancelled dictation, transcript commit, recording blocked during streaming, new-session reset, attachments, and retry. UI tests cover draft/send/stream/complete, dictation cancel, model selection, attachment permission and effort drill-ins, and positive/negative feedback cancellation.

Execution results and synthetic screenshots are recorded below. Test source existence does not itself mean a test was run.

## Known design limitations

This first pass intentionally makes unobserved deep destinations visibly identifiable instead of pretending they match the original. It does not meet full screen-by-screen fidelity yet. Sheet detents, fonts, icon outlines, keyboard transitions, final max composer geometry, light-theme deeper pages, iPad layouts, rotation, accessibility scaling, and motion need further visual comparison. Live app screenshots are the reference; code comments or names are not proof of original implementation.

## Execution evidence

- Xcode 26.4 generic iOS Simulator build succeeded.
- Thirty-four Swift Testing reducer tests passed, covering camera controls as well as stale chunks and completion arriving after a newer request and invalidation across stop, new session, and retry.
- Initial three XCUITest flows passed on a dedicated iPhone 15 Pro simulator, iOS 27.0. Expanded five-test run initially exposed an accessibility selector issue in the effort test; corrected identifiers passed all five tests on rerun.
- Dark and light home screenshots were inspected directly, fixing an incorrect internal font name, safe-area color, and over-bright composer gradient. These are in `screenshots/`; visual inspection is not a claim of exact pixel equivalence.

- Final sheet layout repair was built and both affected XCUITest flows passed again. Exported screenshots of model, effort, and attachment sheets were visually inspected; the model header no longer overlaps the grabber.
- Long draft was re-rendered after preserving intrinsic text-field height; it now grows to approximately 419pt. The observed reference is approximately415pt; this remaining difference is documented rather than called exact.

## Camera reference added

User-provided `IMG_6701.PNG` was inspected at original 1179×2556 resolution (@3x,393×852pt). At reference size the offline presentation uses a full-width 393×524pt portrait preview from y118 to 642, centered flash at y80, 80pt shutter centered y698, and bottom camera controls near y795. No artificial clock, status bar, or privacy indicator is drawn. System status bar is hidden as observed.

The provided screenshot establishes the idle PHOTO state only. VIDEO selection/record/stop, flash cycling, flipping, zoom scaling, and capture handoff are explicit local preview states, not verified copies of the original transitions. Cancelling never attaches media or changes the composer draft. Photo capture attaches a synthetic sample and returns directly; the uncaptured real review UI is intentionally not invented. The preview is injectable, and the bundled scene is original synthetic artwork rather than the user's room.

## Final review and affected validations

- Camera control/cancel/photo-attachment XCUITest passed and its exported screenshot was inspected. A material-composition bug that blurred the selected PHOTO label was corrected and the same flow passed again. `screenshots/camera-photo.png` contains the verified synthetic result.
- Twelve reducer tests passed after the public feedback-payload API update; four editing-state tests were subsequently added and all sixteen passed. Feedback now exposes comment/category to the host only on Submit; cancelling performs no submission. The feedback-cancellation XCUITest passed again after this change.
- Repeated Copy resets its own confirmation timers, preventing an older timer from hiding a newer confirmation early.
- The later live Edit reference established the editing composer and cancellation flow. It is now implemented; both original conversation and prior draft/attachments survive cancel.
- Prior full five-flow UI suite passed; the new sixth camera flow and changed feedback flow were run separately after their changes. No claim is made that all six were rerun together after the camera addition.

## Verified edit reference added

`claude-edit.png` establishes editing in the conversation, retaining the targeted user bubble while hiding later messages, a right-aligned 13pt restart warning, and a 48pt rounded Editing message bar with pencil and cancel X above the prefilled composer. This replaces the temporary placeholder. The simulator fixture `--complete --editing` presents the same state without forcing the software keyboard.

Cancel restores the original conversation and draft. Restoration of an initially empty composer was observed live; preserving an initially nonempty draft and attachments is an explicit host-safe extension. Committing uses the normal Send action, replaces the selected user message, removes later messages, and creates a new response token. Invalid and assistant targets are ignored; blank edit commits retain the editing state. New session abandons the edit so Cancel cannot resurrect a previous conversation.

## Silent Stop and bounded waveform update

**TODO — deferred by the owner on October 8, 2026:** actual Claude speaking waveform geometry, maximum height, smoothing, and transition timing for dictation and voice conversation. Existing silent layouts remain in scope; speaking measurement and reconstruction are excluded from the current polish pass.

`claude-dictation-reply-silent.png` plus the subsequent live Stop action establish a return to the normal composer after a silent recording; there is no paused state in that observed case. The reducer now restores the saved draft and clears transcript/levels on silent Stop. Stop with a nonempty transcript remains explicitly unverified.

`SessionState.dictationLevels` accepts host-provided UI amplitudes only. Finite values clamp to 0…1; nonfinite values map to 0; the newest 256 samples are retained. `DictationWaveformMetrics` resamples within 2.6…24pt heights, preserving silent dots. Maximum audible height 24pt and interpolation80ms are PROVISIONAL implementation bounds until actual phone-speaking video can be captured. They are not copied from desktop Codex or asserted to match Claude mobile. No audio was recorded during this work.

Nineteen reducer tests passed including silent Stop, malformed/nonfinite/out-of-range levels, empty windows, bounded sample count, and level cleanup after cancel/commit/new session. Only the affected dictation UI flow is rerun for this change; prior unrelated UI results retain their stated scope.

Final dictation screenshots were inspected directly: `screenshots/dictation-silent.png` preserves the flat dotted layout, and `screenshots/dictation-levels-provisional.png` exercises injected amplitudes up to the provisional 24pt cap without overflowing the control row. Both screenshots use synthetic conversations; no microphone was active. The affected dictation XCUITest passed after these changes (`claude-ui-dictation-verified.xcresult`), checking silent Stop returns to normal controls and both Stop and Cancel preserve the prior draft.

## Inline voice reference added

The live silent-session references establish an inline voice surface, replacing the earlier unverified full-screen preview. The transcript stays visible; the header has menu and settings circles; assistant actions reduce to thumbs up/down and the AI disclaimer disappears. A 64pt glass microphone sits above the bottom 44pt plus, model, output, and white exit controls. Exiting returns to the standard composer and response actions.

The observed Voice settings sheet contains Clara/Suave cards, a centered selected Suave card, two paging dots, a model row, and Language Beta showing Spanish (Latin America). Model drill-in reuses the captured descriptions and effort page with unversioned model labels. Other language choices were not captured and are not invented. Local selection, microphone/output toggles, and voice preference persistence are supported; their audio consequences and speaking visuals are unverified.

The exit summary uses a local elapsed duration, waveform glyph, thumbs, and dismiss button. Its 62pt glass banner and content follow the captured reference. An eight-second auto-dismiss and immediate local thumb selection are provisional UI behavior: the live banner persisted for several seconds, but exact timing and rating consequences were not observed.

The final voice flow is the eighth unique XCUITest flow, run separately from earlier suites. It checks retained transcript, hidden non-voice actions/disclaimer, selected-card centering and both card selections, model drill-in, restored composer/model on exit, exit summary, local feedback, and dismissal. Twenty-one reducer tests pass with voice entry/exit preservation and incompatible-mode guards. This is not a claim that all eight UI flows were rerun together after voice changes.

Final voice validation passed in `claude-ui-voice-release-fixed.xcresult`; the build performed as part of that run also succeeded. `claude-ui-voice-final-unit.log` records all 21 reducer tests passing. Screenshot review corrected initial carousel positioning and inherited blue banner tint; an explicit rectangular hit area restored full-size dismissal targets. The final exported `screenshots/voice-inline.png`, `voice-settings.png`, `voice-models.png`, and `voice-ended.png` were inspected. This was the voice validation checkpoint; actual phone-speaking amplitude and timing remain open.


## Devices and Dispatch references added

The October 8 continuation captured header Devices and its Manage devices Account route. The Devices sheet is separate from the attachment device selector: its connected desktop row is display-only, with no navigation after two observed taps. The demo uses an explicitly injected fictional desktop; the package starts with no rows and unknown connection status. The rounded group, green indicator, Manage devices gear/chevron, editable fictional profile, instructions, disabled deletion, and organization copy follow the captured structure. New session preserves account/device state while resetting the conversation.

The Account tabs, API keys, photo, guidelines, learn-more, and logout expose typed callbacks. Uncaptured destinations or account consequences are not invented. Only Account is rendered; tapping another tab requests host navigation. Device connection failures and account error/retry visuals are provisional adapter states. The screenshot named `claude-manage-devices-loading.png` already showed a loaded profile on inspection, so the demo’s 500ms spinner is not treated as a measured loading reference. Nested native sheet presentation leaves an approximately 9pt top-position difference from the captured Account page; exact presentation stack remains unconfirmed.

Dispatch uses injected Online status, a roughly32pt grid, warm brown bottom gradient, timestamp with wavy rules, serif welcome content, and a glass task composer. The screenshot named `claude-dispatch-loading.png` also showed loaded content. The live observation of a spinner is recorded separately; its duration and exact rendering remain unmeasured. Offline/unknown/error states are host-facing fallbacks, not captured app states. Submit and attachment taps invoke callbacks but perform no task, clear no draft, and invent no response or menu. The maximum multiline Dispatch composer and keyboard transitions are unverified.

Twenty-eight reducer tests passed, including explicit connection defaults, no implicit account operations, account editing/load guards, stale callbacks after close/reopen/retry, and Dispatch state/navigation. New session invalidates a pending Dispatch load while preserving its draft. Simulator UI validation is recorded after the affected runs below.


Final Devices/Dispatch validation: the two affected flows passed together in `claude-ui-devices-dispatch.xcresult`; Dispatch alone passed again in `claude-ui-dispatch-safearea.xcresult` after correcting its clipped bottom gradient/grid. This brings the executed coverage to ten unique UI flows across the documented scoped runs; a full ten-flow suite was not rerun. The latest reducer run is `claude-ui-dispatch-unit.log` (28 passing). Exported `screenshots/devices-connected.png`, `manage-devices-account.png`, `manage-devices-bottom.png`, and `dispatch-online.png` were inspected. Device review corrected a mid-word organization label wrap and disabled-delete contrast. Account link underline styling and nested sheet top position remain approximate. No real account or remote-task operation was performed.

The final generic iOS Simulator build succeeded after these changes (`claude-ui-devices-dispatch-generic-build.log`, Xcode 26.4, arm64 and x86_64). Source is frozen at this checkpoint pending additional captured references.


## Code and Routines reference continuation

`claude-code-home.png` and `claude-code-filter.png` establish the dark Code home with Devices/Add device, a session list containing status and computer/cloud glyphs, a clock/filter capsule, and floating Search/New session controls. A native Menu/Picker contains All, Needs input, Ready for review, Working, Completed, and Archived. Fictional session titles and metadata replace private project information. Public sessions/devices are injectable; no device is discovered or task started. All currently excludes archived sessions, and status filters preserve injected order—reasonable local semantics, not empirically verified backend queries. Nonempty device-row presentation is provisional; the captured device section was empty. The partial-ring working indicator follows the captured outline, but its one-second local rotation is provisional because no reference timing was measured. It stops animating under Reduce Motion.

The clock was empirically verified to open **Routines**, not history. The empty surface, New routine description textarea, disabled Draft routine, Set up manually, manual Name/Instructions, configuration rows, Trigger choices, and disabled Create follow the captured refs. Schedule expands to Daily at1:00AM, Repeats, and a time capsule; the six native menu labels are captured. Schedule collapse/removal and repeat/time selections work locally. The default daily layout remains for other frequencies until their additional fields are observed. Create eligibility currently requires name, instructions, and a schedule; this guard is provisional, not a claim about server validation. Draft/Create invoke host intents without scheduling or changing the empty list. Back preserves unsaved fields as a host-safe behavior; cancel discards them.

At this checkpoint, session detail, archive consequences, Add device, New session, search, Environment, Repository, Model, Connectors, Notifications, GitHub event, drafting results, and creation results were typed integration hooks with unobserved destinations. Additional Code references are covered below. Their presence is not a claim of whole-app completion. Phone authentication and backend operations remain out of scope.

Thirty-three reducer tests passed in `claude-ui-code-unit.log`, adding every Code status filter, preservation of injected data, inert host actions, navigation isolation, routine draft preservation/cancellation, schedule defaults/range rejection, and no actual creation. Affected simulator validation is recorded below after execution.


The subsequently captured Routines filter uses All, Active, and Inactive with native selected checks. It changes only the local selection because the observed routine list was empty. A 34th state test verifies filtering preserves an unsaved form/schedule and cancellation preserves filter choice. The final state log is `claude-ui-code-final-unit.log` (34 passing). New-scope checklist, partial-ring, branch, two-loop model, and connector glyphs are original vector traces of the observed outlines rather than unrelated stock symbols. Exact path/pixel equivalence is not claimed.


Code/Routines checkpoint: `claude-ui-code-routines-final.xcresult` passed both affected UI flows (42.9s, zero failures), and `claude-ui-code-routines-generic-build.log` records a successful generic arm64/x86_64 simulator build. Nine exported screenshots were inspected: Code home/filter; Routines empty/filter; New routine; manual form top/bottom; Schedule; repeat menu. This is twelve unique UI flows across scoped runs, not a full twelve-flow rerun. Xcode recorded a `_UIReparentingView`/`UIHostingController` diagnostic while native menus appeared; the package performs no manual view reparenting, and both flows passed. The warning remains a runtime observation rather than a claimed fix.


## Code configuration reference continuation

New captures establish the New session composer, sleeping pixel mascot, environment/repository chips, Code-specific model order and Ultracode effort, Choose environment, New cloud environment, four network options, repository list/menu, base branch list/search, Add context and three permission modes, connector discovery/list, tool list and three tool-permission choices. Add device opens Set up remote control with the `claude rc` copy button. The command is displayed/copied only and is never executed.

`CodeDraftState` holds independent model/effort, text, repository/branch, environment form, context mode and connector presentation data. Repository/environment/branch choices validate injected IDs. Back preserves the task draft; cancelling a new environment clears its unsaved variables. Submit, Create environment, connector Add/Connect, media selection, dictation, and repository connection/search are typed host intents with no service operation or invented result. Code camera/media follow-through is not captured and is not implemented by reusing the ordinary-chat capture UI. Environment network labels and permission explanations match the captured menus; saved behavior and server validation remain unobserved.

Connector names, tools and counts in the demo are fictional. Their SF Symbols are explicit stand-ins for the captured provider logos, and are not claimed as exact icon matches. Public connector data supports injected symbols; provider asset rendering remains a fidelity gap. Connector discovery and per-tool/all-tools permission edits affect only local presentation state. The selected-row return behavior and status text after Always allow are provisional because no real permission was changed. Unknown IDs and disconnected rows reject permission edits. The package never connects services.

The sleeping mascot is an original static pixel trace. Its Z animation timing is unmeasured. The Code composer uses a provisional 16-line text cap; its actual long-draft maximum and keyboard behavior require Code-specific capture (ordinary-chat measured limits do not establish Code limits). Repository selection is locally single-select; real multi-selection, branch loading, environment creation, connection flows and task results remain open. Routine configuration rows still expose hooks rather than asserting the Code New session sheets also apply there.

Forty reducer tests pass in `claude-ui-code-configuration-unit.log`. Four affected UI flows passed in `claude-ui-code-configuration.xcresult` (73.1s, zero failures): Code list/Add device regression, draft/model/effort/branch/mode/back, environment cancellation/repository selection, and local connector permissions. Screenshot review found a clipped effort explanation and reversed native repository menu; both were corrected. The affected draft flow passed again in `claude-ui-code-configuration-layout-fixed.xcresult` (20.5s), and its corrected effort/model/menu screenshots were inspected. An intermediate rerun was cancelled after a shell path error meant the intended source edit had not occurred; its result bundle is not validation evidence.

This is fifteen unique executed UI flows across scoped runs, not a full fifteen-flow rerun. The generic arm64/x86_64 build passed in `claude-ui-code-configuration-generic-build.log` before the two final layout changes; the subsequent affected UI run built the updated arm64 target successfully. Final generic validation is coordinated with the parallel Projects implementation. Native menu reparenting diagnostics remain present without test failure.

The new screenshot set is `code-new-session`, `code-models`, `code-effort`, `code-repository-menu`, `code-branches`, `code-context`, `code-permission`, `code-environments`, `code-environment-create`, `code-environment-network`, `code-repositories`, `code-connectors`, `code-connector-tools`, `code-tool-permission`, and `code-add-device` (all `.png` in `screenshots/`). All new screen types were inspected, including the corrected final effort/model/menu renders. Code home/filter screenshots were refreshed during the regression flow. New configuration captures use synthetic data; raw references and diagnostic attachments are excluded.

## Widget checkpoint

The separate ClaudeWidgets product and real embedded WidgetKit extension render the three captured variants. All 55 state tests pass; 20 unique UI flows have passed across scoped runs, including actual installed small-widget Links and all three native gallery pages. The final generic simulator build includes arm64 and x86_64 extension binaries. See [widget evidence and appearance limitations](WIDGETS_REFERENCE.md). Exact light/tinted widget appearance and launcher artwork remain unverified.

## Markdown semantic checkpoint

Assistant text and artifact paragraphs now use a reusable official Swift Markdown AST renderer with independent themes and typed host callbacks. All 64 state/semantic tests pass. Dark/light selection, same-app code Copy/Paste and horizontal table scroll passed; existing chat and artifact regressions passed separately. Generic simulator app+extension build passed after the font/resource additions. This is 21 cumulative unique UI flows across scoped runs. See [supported semantics, validation and provisional styling](MARKDOWN.md); no whole-dialect or Claude rich-block pixel parity is claimed.

## Image and code-viewer checkpoint

The observed recent-photo selection, draft thumbnail removal, sent photo bubble, Copy file name menu and image viewer now use injected metadata/pixels and typed host intents. Code cards and tables follow newly captured Claude references; expanded code opens in a large sheet with a verified top-leading position. All 70 pure tests pass. Final media and Markdown flows passed independently, bringing cumulative unique scoped UI coverage to 22. Six media and ten Markdown synthetic screenshots are included; raw private reference content is excluded. See [image contracts](MEDIA.md) and [rich-text fidelity limits](MARKDOWN.md). The following video checkpoint supersedes the previously unobserved video route. At that checkpoint native full Photos picker integration, image Edit/Share destinations, default syntax coloring and exact selectable inline-code pill corners remained open; later formatting checkpoints below supersede the last two gaps.

## Video file checkpoint

New real references establish the MP4 poster/file-card/large-sheet route, Copy file name menu and Download action. The native Photos picker and Download share sheet remain host integrations; private suggested recipients are not reproduced. The package accepts a typed video descriptor and renderer/lifecycle callbacks. The demo’s original silent 9-second sample uses AVPlayerLayer, with restart and final-frame behavior exercised locally. Real loop/end policy remains unmeasured and host-owned. All 73 pure tests and the combined three-flow video/image/Markdown group pass. A video-only rerun verifies the final white toolbar and reopening. Cumulative coverage is 23 unique scoped UI flows. See [media evidence and integration boundaries](MEDIA.md).

Final video validation: `claude-video-unit.log` (73 tests), `claude-video-ui.xcresult` (three affected flows, 122.215s), `claude-video-final-ui.xcresult` (final video-only rerun, 28.185s), and `claude-video-generic-build.log` (generic simulator app + extension build). Seven synthetic video screenshots and the generated sample are included. No private movie, photo-library content or suggested recipients are exported.


## October 8 Settings checkpoint

Native Settings root, Profile, nested Instructions editor, photo menu, and info menu now follow additional empirical captures. The announcement still has a reusable caller-supplied hero and local dismissal demo; animation timing remains unobserved. See [Settings coverage and validation](SETTINGS.md) for state contracts, captured routes, and missing destinations.

The Profile checkpoint had **83 passing tests** after that extension. Settings dark/light navigation and draft-state UI verification passes separately from the announcement dismissal flow and ordinary chat regression. The cumulative collection now has **25 unique scoped UI flows** (the earlier 23 plus Settings and announcement), not one full 25-flow execution. Avatar catalog, other Settings destinations, and Customize remain incomplete pending references; this is not whole-app completion.


The subsequent Notifications / Time & focus / Privacy extension has **91 passing state tests**. Its three interaction flows pass together (79.086s), checking seven independently stored notification preferences, captured hour/minute choices, and host-owned privacy consent without account writes. See SETTINGS.md for later screenshot refinements and final build results. These bring cumulative unique scoped UI flows to 28; no full 28-flow execution is claimed. The quiet-day selected state and reminder picker's exact embedded-web native presentation remain fidelity gaps.


Usage / Billing / Shared links extends the Settings checkpoint to **99 passing pure tests** and **31 cumulative unique scoped UI flows**. Usage values and financial actions are host-owned, Billing uses the observed website-origin native notice, and shared snapshots contain fictional host-fed read-only messages. Final Shared links verification passes after correcting an accessibility-tree assertion; the earlier combined bundle retains that test failure and must not be described as all-passing. The generic app/widget build succeeds. See [exact evidence and integration limits](SETTINGS.md). Light variants, other subscription origins, and shared-snapshot math/attachments remain qualified gaps.

Claude Code appearance preferences bring the suite to **102 passing pure tests** and **32 cumulative unique scoped UI flows**. The dark/light native-menu and slider flow passes (50.856s), as does the generic app/widget build. Font names are choices for host integration rather than bundled proprietary fonts; transcript size mapping remains unmeasured. Exact evidence is in [Settings](SETTINGS.md).

Capabilities / Memory files extends the package to **108 passing pure tests** and **33 cumulative unique scoped UI flows**. The corrected dark/light interaction flow passes (48.680s) and generic app/widget build succeeds. Testing found and repaired dropped draft characters using a native edit-buffer wrapper. Capability consent, memory generation and deletion remain host integrations; raw private memories are excluded. See [Settings evidence](SETTINGS.md).


The final bounded October 8 Settings batch has **112 passing pure tests** and **34 cumulative unique scoped UI flows**. The final two-flow Memory/Connectors group passes together (83.188s, zero failures), and the generic app/widget build passes. Connector account truth stays host-owned; font/logo and uncaptured-route gaps remain explicit. No full 34-flow rerun or whole-app fidelity claim is made. [Settings](SETTINGS.md) contains the precise logs, screenshot names, previous failures, and source-freeze coverage.


## October 8 connector catalog expansion

Settings now includes the captured All tools selector, plus menu, browsable/filterable connector catalog, and custom connector name/HTTPS URL form. Connection/permission truth remains host-fed; no authentication or MCP transport is implemented. Final pure suite: **117 passing tests** (`claude-connectors-catalog-unit.log`). Generic app/widget build passes (`claude-connectors-catalog-generic.log`). Existing policy/bulk flow passes both appearances in 38.162s; corrected catalog/custom flow passes in 59.358s and settled render rerun in 64.704 seconds. The initial catalog bundle contains a corrected accessibility-identifier failure and must not be described as fully passing. There are **35 cumulative unique passing scoped UI flows**, not a complete 35-flow run. See [Settings coverage](SETTINGS.md) for evidence and limitations.


## October 8 priority rich-text refinement

Code cards and expanded code now use pinned offline HighlighterSwift 3.1.0 / bundled highlight.js 11.11.1, returning native foreground attributes while preserving font/layout/selection and source-copy text. Atom One Dark follows the captured Python palette; at this checkpoint Atom One Light was provisional pending the subsequent light reference. Five new source-preservation/fallback/theme tests bring the pure suite to **122 passing** (`claude-syntax-unit.log`). Generic app/widget build passes (`claude-syntax-generic.log`). Two existing native UI flows pass together in **78.418s** (`claude-syntax-ui.xcresult`): ordinary chat11.148s and Markdown both appearances67.270s. Ten synthetic Markdown images were refreshed; dark/light code cards and expanded views were visually inspected. Unique scoped flow coverage remains35, not a full35-flow run. See [Markdown contracts and remaining gaps](MARKDOWN.md). Speaking-waveform work remains explicitly deferred; no new feature page or system surface was added.


## Final captured-priority refinement

Short tables now fit the transcript using measured columns; wider tables scroll. Rounded blue inline code preserves native selection in paragraphs and table cells. Captured light Python code cards are white, and the static composer voice icon follows the measured six unequal bars. Video-file toolbar ink now adapts to the captured light/dark appearances.

Final bounded verification: **127 pure tests pass** (`claude-table-unit.log`), including five new table/nested-inline-code cases. Generic simulator app, embedded widget and UI-test build passes (`claude-table-build.log`). The final dark/light formatting flow passes in **68.248s** (`claude-table-markdown-verified.xcresult` / `.log`), asserting native selection, exact code Copy/Paste, expanded-code position/dismissal, all three compact columns visible and long-table horizontal navigation. The video flow now passes both appearances in **58.549s**, and the existing chat regression passes in **10.507s**, within `claude-table-final-ui.xcresult` / `.log`. That earlier combined bundle is not wholly passing: its formatting flow had two stale pre-tap visibility assertions caused by a fixed swipe loop overshooting the shorter transcript. Target-based native auto-scroll replaces the loop in the fully passing formatting rerun.

Twelve current synthetic Markdown and fourteen video screenshots are included and representative dark/light paragraph, compact table, code/expanded views and adaptive video toolbar renders were inspected. Existing unique scoped UI coverage remains **35**, not one complete 35-flow execution. No private reference media is exported. Remaining reference gaps, speaking waveform, additional feature pages, system surfaces and unmeasured animation timing are TODO; no further phone investigation is part of this checkpoint.
