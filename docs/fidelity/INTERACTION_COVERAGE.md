# Interaction coverage

Static screenshots are one input. A matching skeleton must also reproduce visible changes caused by typing, pressing, selection, navigation, message completion, and dismissal. Record each transition independently; an implemented destination screen does not establish a verified animation into it.

Use the following record shape for implementation and comparison evidence:

```json
{
  "id": "composer.empty-to-text.light",
  "source": "new-chat/composer-empty",
  "trigger": "type a short fictional message",
  "destination": "new-chat/composer-nonempty",
  "theme": "light",
  "referenceEvidence": ["capture-filename.png"],
  "implementationEvidence": [],
  "referenceStatus": "observed",
  "implementationStatus": "unverified",
  "assertions": ["send action replaces idle voice action", "composer grows only when needed"],
  "knownGaps": ["transition timing has not been measured"]
}
```

Reference status: `unknown`, `capture-available`, `observed`, or `blocked`. Implementation status: `unverified` (implementation not yet inspected), `not-implemented`, `implemented-unverified`, `verified`, or `mismatch`. `verified` requires actually comparing the rendered skeleton and behavior with the reference under a documented configuration. If a state is unavailable on the reference account/device, record the limitation.

## Required state families

| Family | States/transitions to inspect |
|---|---|
| Composer | Empty -> typing -> multiline -> maximum height -> internal scrolling; clear text; keyboard enter/dismiss; attachment with/without text |
| Feature selection | Open picker; pressed row; selected icon/color/label; cancel; change selection; persistence across dismiss/reopen |
| Native surfaces | Attachment menu, sheets, nested sheets, context menu, dimming/background blur, touch-down glass, outside tap, swipe dismissal |
| Sending | Send action -> user bubble -> waiting/thinking -> streaming -> complete; stop; error; retry; input during response |
| Message actions | Long press; copy and confirmation feedback; selection; positive/negative rating and follow-up; retry; read-aloud play/pause/stop |
| Dictation | Start, permission/unavailable, elapsed time and levels, cancel, stop, processing, resulting transcript; empty/no-audio state |
| Voice conversation | Entry, listening, speaking, interruption, muted/unavailable, exit; list as unknown if not observed |
| Navigation | Sidebar open/close, search, selection, new chat, settings hierarchy, back gesture, sheet close, scroll position |
| Appearance | Light and dark, enabled/disabled, selected/unselected, reduced motion, text-size behavior |

For native controls, appearance and motion depend on OS version. Record timing from video if a motion match is claimed; guessed spring constants or a pair of still frames are not measured fidelity.

## Current evidence caveats

The initial collection used iPhone Mirroring with the software keyboard hidden. A multiline composer height of approximately 414.5 points was observed in a 393 × 852 point mirrored content area; this measurement is specific to that condition, not a universal layout constant. Silent dictation controls were visible, but microphone audio capture was unavailable through Mirroring. Simulated waveforms, transcripts, or playback are demo UI and must be marked as such.

## Live-reference findings added during this pass

The reference manifest contains transition records with filenames and observation notes. These are observations of the originals; they do not certify the current skeleton implementation.

| Interaction | Reference |
| --- | --- |
| Typed composer | Voice changes to orange send |
| Long draft in Mirroring | Approximately 414.5pt cap with internal scrolling |
| Copy | Checkmark and top glass toast |
| Positive rating | Optional feedback sheet |
| Negative feedback cancel | Returns to unselected rating |
| Assistant long press | Two live holds produced no context menu |
| Read aloud | Play triangle ↔ two outlined pause bars observed |
| Silent dictation | Cancel circle, dotted waveform, stop, orange send |
| Appearance restored to System | Returned to dark after restoration |

A native menu is appropriate only if its actual rendered structure matches the reference. Retain native material and interaction where suitable, and inspect custom content rather than assuming a system API guarantees fidelity.

Source app version observed in-app: Claude **1.261002.20 (37091698851)**. This value identifies the captured build; it is not a promise that the reference will stay current. Mirroring could not provide live microphone input, so waveform behavior during speech and transcription results remain unverified.

Direct camera reference supplements: one user-supplied native iPhone PNG (`IMG_6701.PNG`) was verified from its PNG header at 1179 × 2556 pixels. The supplied @3x scale corresponds to 393 × 852 points. See `REFERENCE_CAPTURE_GUIDE.md` for private-archive handling; camera interaction validation is recorded in `VALIDATION.md`.

Claude voice conversation is now observed in four private references: inline silent voice, Voice settings, Select model, and Voice chat ended. These establish visible controls/settings and exit appearance; they do not establish speech animation, maximum waveform height, or transition timing because Mac Mirroring cannot supply microphone audio. Claude’s final affected voice UI flow and simulator build passed; 21 reducer tests passed.

## Video media

Image and video open/close currently use native/default presentation; vendor easing, interactive dismissal and gesture timing are unmeasured. No original movie, camera-roll photo or other private capture is included in the export.

Video uses a distinct file path. Native picker selection leads to an approximately 80-point composer poster with no duration label; sending produces an approximately 140-point square MP4 file card, with gray file glyph placeholder and middle-truncated filename. Its long press exposes Copy file name only. The sheet viewer retains status and uses a material filename header with Close and a Download-only menu. The collector observed playback ending on the final frame; the misnamed playback-controls capture shows that movie frame, not a transport bar. Buttons from other apps and Control Center that are visible in the recording are not viewer controls. The separate video-file implementation passed the combined Markdown/image/video UI run and final video rerun. Download opens a native share sheet in the source; native sharing remains a host integration. Playback end/loop policy is provisional. Original media remains private.

## Bounded phase2 checkpoint

Settings subpages now have scoped local-state and rendered interaction checks. The 112-test independent snapshot is historical; later verified counts are recorded in the current snapshot validation report. No count establishes all-route UI or motion parity. Privacy consent, capability truth, memory deletion, credit actions and connector policies remain host-fed intents. The All tools/add/custom/browse connector screens were implemented and scoped UI checked at the 117-test checkpoint; host-only connection and policy outcomes remain outside the package. See `ROUTE_COVERAGE.md` and each child Settings guide for exact scope. Private captures never become distribution assets.

## Active polish boundary

The current user-authorized pass covers existing media/text/voice states, icons, light/dark appearance and reference-measured animation. Remaining feature pages and system surfaces are deferred TODOs. Speaking waveform work is explicitly deferred; silent controls and preview clamps cannot establish speech maxima or timing. The previous 112-test independent export remains a historical checkpoint and predates the now-frozen syntax/table/inline-code and existing-presentation refinements. All remaining gaps are TODO.
