# Route coverage checkpoint

## Current priority and deferred TODOs — October 8

**Finalization instruction:** all phone investigation has stopped. Finalize the currently known implementation; every remaining gap below is a TODO for a future pass, not permission to expand this delivery.

The owner narrowed the active pass to existing media presentation, text formatting, captured voice states, icons, light/dark appearance, and animations supported by measured references. Preserve completed routes while polishing those surfaces. The broader app inventory below is retained for future work; missing feature pages are **deferred TODOs**, not requirements to add during this pass.

- **TODO, deferred:** remaining feature destinations.
- **TODO, deferred:** further system surfaces, Lock Screen/ActivityKit and other uncaptured widget states.
- **TODO, deferred:** speaking waveform capture and reconstruction, including maximum height, amplitude mapping, smoothing and timing. Existing silent/idle states remain in scope; provisional bounds are not measured speech behavior.
- **Active:** image/video presentation and existing rich text/voice/icons/themes. Only measured motion can support fidelity claims; default native transitions and sampled endpoints remain explicitly provisional.

The final known-scope source is frozen. Independent snapshot results are recorded separately; all remaining gaps are explicit TODOs. The12:07:05 ZIP predates this final polish.

The final source state suite passes 127 tests. Existing media/text/voice regression checks passed at their scoped checkpoints; the whole signed-in app is not complete.

This is a provisional inventory of the current source, not a completion declaration. The requested scope is the whole signed-in app UI. Missing destinations still belong to that scope; backend-free does not excuse a missing interface. Captured means a source reference exists, implemented means a local layout exists, and verified requires rendered interaction comparison. Authentication onboarding remains excluded; feature onboarding is included.

| Destination | Reference coverage | Current implementation / remaining work |
|---|---|---|
| Session/composer/conversation | Captured idle/typed/sent/copy/feedback/edit/dictation | Local transitions and layouts; actual speech geometry under separate video analysis |
| Inline Voice | Idle/settings/models/ended captured | Implemented and targeted UI checked; speaking/animation analysis ongoing |
| Devices / Dispatch | Connected device sheet, Manage devices, Dispatch online captured | Device and Dispatch layouts implemented; two targeted UI flows and safe-area rerun passed. Actual remote-session interaction remains a separate gap |
| Code / Routines | Code home/filter/model/effort, Routines empty/filter/new/manual/schedule/repeat and new-session captured | Local Code/Routines/new-session/configuration implementation and scoped rendered checks passed; included in final53-state-test/generic build checkpoint. No real code execution or routine service |
| Attachment Permission / Devices | Captured parent and selector sheets | Local choices; no real permissions/connections |
| Projects | Empty/filter/introduction/setup/icon/context/Drive/environment captured | Implemented local draft/host-action state; 9 state tests and targeted UI flow passed. Populated/archived/detail/creation outcome unverified; SF icons/illustration approximate |
| Artifacts | List/filter/document viewer captured | Implemented injected list/document data and local collapse; state/UI/build checks passed. Tab menu, other artifact viewers, share/comment/edit outcomes unobserved |
| Customize | No complete detail reference | Placeholder destination; capture and implementation remain required |
| Settings details | Parent/Profile/Instructions, photo menu/avatar chooser, Notifications and Info menu captured; footer captures do not prove an endpoint | Parent/Profile/Instructions/local preferences passed dark/light scoped UI (75.823s), with112 state tests at the frozen checkpoint. Notifications/Time & focus/Privacy implemented and three-flow UI passed79.086s, plus final Notifications/Privacy rerun56.553s. Usage/Billing/Shared links implemented with scoped passing cases and corrected Shared rerun. Code preferences passed50.856s UI; exact font files/text-size mapping unverified. Capabilities/Memory and Connectors root/tool/policy pass their final2-flow UI83.188s. All tools/add menu/custom connector/browse/sort were subsequently implemented and scoped UI checked at the117-test checkpoint; later polish is active. Avatar chooser, Permissions and Settings→Voice still require destination-specific validation |
| Feature announcement | Still captured; relaunch partial frames show ordinary home, not replay | Still layout and both dismissal controls passed (19.154s); illustration animation and exact motion remain unmeasured |
| Photos / Files / Add to project | Parent attachment sheet captured | Generic sample selection; deeper native picker parity unverified |
| Markdown | Heading/list/quote/code/table references captured; expanded code captured | Official Swift Markdown AST parsing, selectable text and scoped UI checks passed. Exact syntax colors/inline-code corners and complete rich-content coverage remain limited; child Markdown guides specify renderer hooks |
| Video files | Native picker selection, 80-point composer poster without duration, 140-point sent MP4 card, Copy file name hold, filename sheet and Download-only menu captured | Separate typed file-viewer implementation and final rendered UI checks passed. Download emits a host intent; native share sheet observed in source. Collector observed playing then holding last frame; no actual transport bar or timing established |
| Sent images | Recent picker/selection, composer, sent image/context menu, viewer and hidden controls captured | Final photo UI passed (30.745s). Full library and editor/share destinations are host intents. The native full-picker layout is newly captured, not locally reproduced |
| Camera | Native photo reference | Local camera controls/capture state; synthetic scene; actual camera adapter external |
| Home Screen widgets | Three gallery previews captured and inspected | Genuine WidgetKit app extension built and native simulator gallery/route checks passed. Original-app configurations and tap outcomes and alternate appearances remain unverified |
| Lock Screen Live Activities | Actual surface reference pending | Separate ActivityKit interface not implemented; backend delivery remains external |
| Dynamic Island | Reference pending | Not implemented; no ActivityKit claim |

Do not count an alert, disabled button, generic placeholder, or backend action hook as a faithfully implemented destination. Update this inventory after each new capture and rendered check, then refresh `reference-manifest.json` and `VALIDATION.md` before exporting.

Scope update: ordinary app login/onboarding remain excluded as originally requested. Feature-specific onboarding and connected/disconnected/error states are explicitly required; where they are not yet captured they still require references and implementation.
