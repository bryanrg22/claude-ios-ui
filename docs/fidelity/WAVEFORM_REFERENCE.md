# Dictation waveform reference status

## Current scope: speaking waveform deferred

**TODO — deferred at the owner's request on October 8, 2026:** capture and measure the speaking waveform, including quiet/loud/silent levels, maximum height, smoothing, timing, and Stop/transcription transitions. This applies to dictation and voice conversation. Keep existing silent-state evidence and provisional preview bounds; do not present them as measured speaking behavior. A direct phone recording is required to resolve this TODO; it is outside the current polishing pass.

Waveform geometry, silence, level changes, state transitions, and clipping are UI responsibilities. Audio capture, amplitude analysis, transcription, and speech synthesis remain adapter responsibilities. The mobile app needs its own reference; desktop appearances are not evidence of mobile parity.

## Evidence recorded October 7, 2026

| Reference | Verified observation | Still unknown |
|---|---|---|
| Claude iOS | Reply placeholder above a silent dotted line; cancel/Stop/orange send controls; silent Stop returns normal composer | Speaking bar heights, actual maximum height, level smoothing, animation timing, stop after captured speech |
| Claude voice conversation | Inline idle voice UI, settings sheet, model picker, and exit banner captured | Speaking waveform, maximum height, audio response, and transition timing |

## Implementation contract

- Hosts supply normalized amplitude samples and a transcript. No microphone is opened by the UI package.
- An empty or zero-level signal renders silence. Invalid or nonfinite values must not produce invalid view geometry.
- UI bounds must constrain bars at every supplied level. Current preview bounds are provisional; they are not measured speaking maxima.
- Cancel restores the earlier draft. Stop with no recorded content returns to the ordinary composer in the observed mobile references.
- Captured-speech processing, paused, retry, and error states require separate reference evidence. Do not infer them from silence.

## Measurements still required

Capture the mobile app speaking quietly and loudly, then silence, Stop, cancel, and transcription completion. Include app version, iOS version, phone, theme, display/text settings, and recording frame rate. Measure peak height in points using the known capture scale; confirm repeated peaks at saturation before calling a height the maximum. Track bar width, spacing, baseline, scrolling direction, decay, and easing across frames. Save raw footage privately and publish only synthetic comparison captures and derived measurements.

Apple iPhone Mirroring reports that the microphone is unavailable from the Mac, so these speaking measurements cannot be established through the current mirrored capture route.

## Voice captures added

`claude-voice-idle.png`, `claude-voice-settings.png`, `claude-voice-models.png`, and `claude-voice-ended.png` establish the silent inline voice layout and its settings/model/exit surfaces. The transcript remains visible; the ended banner returns above the ordinary chat interface. Its displayed 43s duration is a captured label, not an animation measurement. These captures do not establish speaking waveform height or timing. No dictation-bar maximum has been measured.

The private archive preserves the complete Mirroring PNG inventory and the direct camera screenshot. Raw files are ignored by Git and excluded from exports; only portable names and derived status/measurements belong in shared metadata.
