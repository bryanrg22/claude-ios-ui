import ClaudeUI
import SwiftUI

// Live Xcode previews for every catalogued screen, in both appearances, driven by the same `DemoScreen` list the
// screenshot tests and `--screen` launch argument use. Open this file in Xcode and use the canvas to iterate on a
// screen without launching the demo. Each preview shows the fixture data the demo and tests show.

#Preview("Home · light") { DemoScreenView(screen: .home, appearance: .light) }
#Preview("Home · dark") { DemoScreenView(screen: .home, appearance: .dark) }
#Preview("Typed · light") { DemoScreenView(screen: .typed, appearance: .light) }
#Preview("Typed · dark") { DemoScreenView(screen: .typed, appearance: .dark) }
#Preview("Long draft · light") { DemoScreenView(screen: .longDraft, appearance: .light) }
#Preview("Long draft · dark") { DemoScreenView(screen: .longDraft, appearance: .dark) }
#Preview("Conversation · light") { DemoScreenView(screen: .conversation, appearance: .light) }
#Preview("Conversation · dark") { DemoScreenView(screen: .conversation, appearance: .dark) }
#Preview("Editing · light") { DemoScreenView(screen: .editing, appearance: .light) }
#Preview("Editing · dark") { DemoScreenView(screen: .editing, appearance: .dark) }
#Preview("Temporary · light") { DemoScreenView(screen: .temporary, appearance: .light) }
#Preview("Temporary · dark") { DemoScreenView(screen: .temporary, appearance: .dark) }
#Preview("Dictation · light") { DemoScreenView(screen: .dictation, appearance: .light) }
#Preview("Dictation · dark") { DemoScreenView(screen: .dictation, appearance: .dark) }
#Preview("Waveform · light") { DemoScreenView(screen: .waveform, appearance: .light) }
#Preview("Waveform · dark") { DemoScreenView(screen: .waveform, appearance: .dark) }
#Preview("Voice · light") { DemoScreenView(screen: .voice, appearance: .light) }
#Preview("Voice · dark") { DemoScreenView(screen: .voice, appearance: .dark) }
#Preview("Markdown · light") { DemoScreenView(screen: .markdown, appearance: .light) }
#Preview("Markdown · dark") { DemoScreenView(screen: .markdown, appearance: .dark) }
#Preview("Video draft · light") { DemoScreenView(screen: .videoDraft, appearance: .light) }
#Preview("Video draft · dark") { DemoScreenView(screen: .videoDraft, appearance: .dark) }
#Preview("Image viewer · light") { DemoScreenView(screen: .imageViewer, appearance: .light) }
#Preview("Image viewer · dark") { DemoScreenView(screen: .imageViewer, appearance: .dark) }
#Preview("Artifacts · light") { DemoScreenView(screen: .artifacts, appearance: .light) }
#Preview("Artifacts · dark") { DemoScreenView(screen: .artifacts, appearance: .dark) }
#Preview("Artifact document · light") { DemoScreenView(screen: .artifactDocument, appearance: .light) }
#Preview("Artifact document · dark") { DemoScreenView(screen: .artifactDocument, appearance: .dark) }
#Preview("Code · light") { DemoScreenView(screen: .code, appearance: .light) }
#Preview("Code · dark") { DemoScreenView(screen: .code, appearance: .dark) }
#Preview("Code new session · light") { DemoScreenView(screen: .codeNewSession, appearance: .light) }
#Preview("Code new session · dark") { DemoScreenView(screen: .codeNewSession, appearance: .dark) }
#Preview("Dispatch · light") { DemoScreenView(screen: .dispatch, appearance: .light) }
#Preview("Dispatch · dark") { DemoScreenView(screen: .dispatch, appearance: .dark) }
#Preview("Projects · light") { DemoScreenView(screen: .projects, appearance: .light) }
#Preview("Projects · dark") { DemoScreenView(screen: .projects, appearance: .dark) }
#Preview("Devices sheet · light") { DemoScreenView(screen: .devicesSheet, appearance: .light) }
#Preview("Devices sheet · dark") { DemoScreenView(screen: .devicesSheet, appearance: .dark) }
#Preview("Settings · light") { DemoScreenView(screen: .settings, appearance: .light) }
#Preview("Settings · dark") { DemoScreenView(screen: .settings, appearance: .dark) }
#Preview("Settings profile · light") { DemoScreenView(screen: .settingsProfile, appearance: .light) }
#Preview("Settings profile · dark") { DemoScreenView(screen: .settingsProfile, appearance: .dark) }
#Preview("Settings notifications · light") { DemoScreenView(screen: .settingsNotifications, appearance: .light) }
#Preview("Settings notifications · dark") { DemoScreenView(screen: .settingsNotifications, appearance: .dark) }
#Preview("Settings time & focus · light") { DemoScreenView(screen: .settingsTimeAndFocus, appearance: .light) }
#Preview("Settings time & focus · dark") { DemoScreenView(screen: .settingsTimeAndFocus, appearance: .dark) }
#Preview("Settings privacy · light") { DemoScreenView(screen: .settingsPrivacy, appearance: .light) }
#Preview("Settings privacy · dark") { DemoScreenView(screen: .settingsPrivacy, appearance: .dark) }
#Preview("Settings usage · light") { DemoScreenView(screen: .settingsUsage, appearance: .light) }
#Preview("Settings usage · dark") { DemoScreenView(screen: .settingsUsage, appearance: .dark) }
#Preview("Settings billing · light") { DemoScreenView(screen: .settingsBilling, appearance: .light) }
#Preview("Settings billing · dark") { DemoScreenView(screen: .settingsBilling, appearance: .dark) }
#Preview("Settings shared links · light") { DemoScreenView(screen: .settingsSharedLinks, appearance: .light) }
#Preview("Settings shared links · dark") { DemoScreenView(screen: .settingsSharedLinks, appearance: .dark) }
#Preview("Settings capabilities · light") { DemoScreenView(screen: .settingsCapabilities, appearance: .light) }
#Preview("Settings capabilities · dark") { DemoScreenView(screen: .settingsCapabilities, appearance: .dark) }
#Preview("Settings memory files · light") { DemoScreenView(screen: .settingsMemoryFiles, appearance: .light) }
#Preview("Settings memory files · dark") { DemoScreenView(screen: .settingsMemoryFiles, appearance: .dark) }
#Preview("Settings code · light") { DemoScreenView(screen: .settingsCode, appearance: .light) }
#Preview("Settings code · dark") { DemoScreenView(screen: .settingsCode, appearance: .dark) }
#Preview("Settings connectors · light") { DemoScreenView(screen: .settingsConnectors, appearance: .light) }
#Preview("Settings connectors · dark") { DemoScreenView(screen: .settingsConnectors, appearance: .dark) }
#Preview("Announcement · light") { DemoScreenView(screen: .announcement, appearance: .light) }
#Preview("Announcement · dark") { DemoScreenView(screen: .announcement, appearance: .dark) }
#Preview("Camera") { DemoScreenView(screen: .camera, appearance: .dark) }
#Preview("Widgets") { DemoScreenView(screen: .widgets, appearance: .dark) }
