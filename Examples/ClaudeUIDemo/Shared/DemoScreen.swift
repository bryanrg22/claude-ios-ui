/// Every screen the demo can open directly, by name.
///
/// One list, compiled into three targets: the demo app (`--screen <name>` opens that screen), the screenshot
/// tests (one light and one dark reference image per case) and the UI tests (one accessibility audit per case).
/// Adding a case here adds it to all three.
enum DemoScreen: String, CaseIterable, Sendable {
    case home, typed, longDraft, conversation, editing, temporary, dictation, waveform, voice
    case markdown, videoDraft, imageViewer
    case artifacts, artifactDocument, code, codeNewSession, dispatch, projects
    case devicesSheet
    case settings, settingsProfile, settingsNotifications, settingsTimeAndFocus, settingsPrivacy
    case settingsUsage, settingsBilling, settingsSharedLinks, settingsCapabilities, settingsMemoryFiles
    case settingsCode, settingsConnectors
    case announcement, camera, widgets
}
