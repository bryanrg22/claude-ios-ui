# Dictation waveform reference status

## Current scope: Claude speaking waveform deferred

**TODO — deferred at the owner's request on October 8, 2026:** capture and measure Claude's speaking waveform, including quiet/loud/silent levels, maximum height, smoothing, timing, and Stop/transcription transitions. This applies to dictation and voice conversation. Keep existing silent-state evidence and provisional preview bounds; do not present them as measured speaking behavior. A direct phone recording is required to resolve this TODO; it is outside the current polishing pass.

Waveform geometry, silence, level changes, state transitions, and clipping are UI responsibilities. Audio capture, amplitude analysis, transcription, and speech synthesis remain adapter responsibilities. Each app needs its own reference; desktop appearances are not evidence of mobile parity.

## Evidence recorded October 7, 2026

| Reference | Verified observation | Still unknown |
|---|---|---|
| ChatGPT iOS | Silent dotted line; cancel, stop, and send controls; silent Stop returns normal composer | Speaking bar heights, actual maximum height, level smoothing, horizontal movement, timing, behavior after captured speech |
| Claude iOS | Reply placeholder above a silent dotted line; cancel/Stop/orange send controls; silent Stop returns normal composer | Speaking bar heights, actual maximum height, level smoothing, animation timing, stop after captured speech |
| Claude voice conversation | Inline idle voice UI, settings sheet, model picker, and exit banner captured | Speaking waveform, maximum height, audio response, and transition timing |
| ChatGPT voice conversation | Breeze chooser, idle voice, settings, language menu, and supplied talking recording inspected; large and compact orb bounds and keyboard/transcript transitions sampled | Hard diameter cap, loudness-to-radius relationship, exact easing, other voices, full language catalog |
| Supplied Codex desktop still | Image is 994 × 224 pixels; visible waveform peak is 50 pixels tall in this frame | Display scale, maximum permitted peak, timing, audio level at capture, whether either iOS app shares this design |

The desktop peak was measured from bright waveform pixels within x115..818/y125..194 of the original image. It describes one observed frame, not a maximum cap or a value in iOS points. The raw image is stored only in the ignored local private reference archive.

## Implementation contract

- Hosts supply normalized amplitude samples and a transcript. No microphone is opened by the UI package.
- An empty or zero-level signal renders silence. Invalid or nonfinite values must not produce invalid view geometry.
- UI bounds must constrain bars at every supplied level. Current preview bounds are provisional; they are not measured speaking maxima.
- Cancel restores the earlier draft. Stop with no recorded content returns to the ordinary composer in the observed mobile references.
- Captured-speech processing, paused, retry, and error states require separate reference evidence. Do not infer them from silence.

## Measurements still required

Capture each mobile app speaking quietly and loudly, then silence, Stop, cancel, and transcription completion. Include app version, iOS version, phone, theme, display/text settings, and recording frame rate. Measure peak height in points using the known capture scale; confirm repeated peaks at saturation before calling a height the maximum. Track bar width, spacing, baseline, scrolling direction, decay, and easing across frames. Save raw footage privately and publish only synthetic comparison captures and derived measurements.

Apple iPhone Mirroring reports that the microphone is unavailable from the Mac, so these speaking measurements cannot be established through the current mirrored capture route.

## Claude voice captures added

`claude-voice-idle.png`, `claude-voice-settings.png`, `claude-voice-models.png`, and `claude-voice-ended.png` establish the silent inline voice layout and its settings/model/exit surfaces. The transcript remains visible; the ended banner returns above the ordinary chat interface. Its displayed 43s duration is a captured label, not an animation measurement. These captures do not establish Claude speaking waveform height or timing. Neither app has a measured dictation-bar maximum.

The private archive now preserves the complete Mirroring PNG inventory, the `motion-chat-work/` directory including `times.json`, the nine direct camera screenshots, and the desktop waveform still. Raw files are ignored by Git and excluded from exports; only portable names and derived status/measurements belong in shared metadata.

## ChatGPT voice captures added

`chatgpt-choose-voice-breeze.png`, `chatgpt-voice-idle.png`, `chatgpt-voice-settings-breeze.png`, and `chatgpt-voice-language-{1,2}.png` establish the Breeze chooser, silent voice layout, settings, and part of the language menu (Auto plus 14 named entries). Other voice profiles and the full language catalog remain unverified.

## Derived ChatGPT talking-recording measurements

The supplied 90.235-second recording was inspected and sampled at native presentation timestamps, approximately 11.93 samples per second. The original is 1180 × 2556 pixels, with an average rate of 59.66 frames per second. Bounds were detected at half resolution and converted back to native pixels, giving approximately ±2 pixels of spatial uncertainty. Point conversions below assume approximately 3× capture scale; the native pixel measurements are authoritative.

| Observed interval | Sampled orb diameter | Observation |
|---|---|---|
| Stable large mode, 2–19.5 seconds | 494–654 px (approximately 164.7–218 pt) | Circular cloud silhouette centered near (590, 1313) px |
| Startup, 1.583 seconds | 674 px (approximately 224.7 pt) | Observed startup overshoot; not a recovered design maximum |
| Compact mode, 26–41.5 seconds | 208–272 px (approximately 69.3–90.7 pt) | Center near (590, 2130) px |

Keyboard entry at approximately 20.04–20.54 seconds moves the large orb center from y1313 to y852 px while diameter stays near 574 px. Transcript arrival at approximately 21.54–22.04 seconds reduces diameter from 594 to 236 px and moves the orb toward y1210 px. Keyboard dismissal at approximately 23.29–23.79 seconds moves the compact orb from y1212 to y2130 px without expanding it. These are sampled transition windows with approximately 0.085-second spacing, not exact durations or fitted easing curves.

The recording also establishes the effort overlay, live transcript, voice attachment menus, model-switch prompt for screen sharing, stop-sharing menu, and live camera controls. The cloud texture changes within the circular silhouette. The UI implementation uses an original procedural approximation; its texture and motion are not an exact reconstruction. Occluded and system-transition samples at 62–68.5 seconds were rejected after visual inspection.

There are no waveform bars in this recording. It supplies no dictation bar maximum, amplitude mapping, or evidence for Claude voice geometry. The private `video-talking/measurements.json`, timestamped CSV, analysis, and extracted frames preserve the evidence and exclusions. Earlier Mirroring microphone limitations describe that capture route, not an inability to analyze a direct recording.
