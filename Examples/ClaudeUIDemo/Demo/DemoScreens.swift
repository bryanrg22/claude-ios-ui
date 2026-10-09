import ClaudeUI
import SwiftUI

extension DemoScreen {
    /// The screen named after `--screen` in the launch arguments, if any.
    init?(launchArguments: [String]) {
        guard let index = launchArguments.firstIndex(of: "--screen"), index + 1 < launchArguments.count else {
            return nil
        }
        self.init(rawValue: launchArguments[index + 1])
    }
}

/// Shows one `DemoScreen` with the demo fixtures, the way the app presents it.
/// The app uses this for `--screen <name>`; the screenshot tests render the same view.
struct DemoScreenView: View {
    private let screen: DemoScreen
    private let state: SessionState

    init(screen: DemoScreen, appearance: ClaudeAppearance) {
        var state = SessionState()
        state.installDemoFixtures()
        configureDemoScreen(screen, on: &state)
        state.appearance = appearance
        self.screen = screen
        self.state = state
    }

    var body: some View { Self.view(for: screen, state: state) }

    static func view(for id: DemoScreen, state: SessionState) -> AnyView {
        switch id {
        case .camera:
            AnyView(
                ClaudeCameraView(onCancel: {}, onCapture: { _ in }) {
                    LinearGradient(colors: [.gray, .black], startPoint: .top, endPoint: .bottom)
                })
        case .widgets: AnyView(WidgetPreview())
        case .announcement:
            AnyView(
                SessionHost(state: state) { _ in
                    AnyView(
                        ClaudeWorkAnnouncementView(onDismiss: {}) { ClaudeWorkAnnouncementStill() }
                            .presentationDetents([.large]).presentationCornerRadius(40)
                            .presentationDragIndicator(.hidden))
                })
        case .devicesSheet:
            AnyView(SessionHost(state: state) { AnyView(ClaudeDevicesView(state: $0.devices, action: { _ in })) })
        default:
            if id == .settings || demoSettingsDestination(for: id) != nil {
                AnyView(
                    SessionHost(state: state) { binding in
                        AnyView(
                            ClaudeSettingsView(
                                state: binding.settings, appearance: binding.wrappedValue.appearance, action: { _ in }))
                    })
            } else {
                AnyView(SessionHost(state: state, sheet: nil))
            }
        }
    }
}

/// Mirrors the demo's launch arguments and simulated host replies for each screen.
func configureDemoScreen(_ id: DemoScreen, on state: inout SessionState) {
    switch id {
    case .typed: state.draft = "Reply with a short greeting."
    case .longDraft:
        state.draft = String(repeating: "A thoughtful interface makes room for the details. ", count: 32)
    case .conversation, .editing:
        state.messages = [
            .init(role: .user, text: "Reply with a short greeting."),
            .init(role: .assistant, text: "Hey Jordan! What's on your mind tonight?")
        ]
        if id == .editing, let message = state.messages.first { state.reduce(.beginEditing(message.id)) }
    case .temporary: state.reduce(.toggleTemporary)
    case .dictation: state.reduce(.startDictation)
    case .waveform:
        state.reduce(.startDictation)
        state.dictationLevels = [0, 0.1, 0.3, 0.8, 1, 0.5, 0.2, 0, 0.4, 0.7, 1, 0.3, 0.1, 0]
    case .voice: state.reduce(.startVoice)
    case .markdown: state.messages = [.init(role: .assistant, text: MarkdownFixture.source)]
    case .videoDraft:
        state.media.draft = [
            .init(
                id: "garden-video", fileName: "Garden-Motion.mp4", accessibilityDescription: "Garden motion video",
                aspectRatio: 240.0 / 426, kind: .video)
        ]
    case .imageViewer:
        if let photo = state.media.recent.first { state.reduce(.media(.open(photo))) }
    case .artifacts: state.reduce(.openArtifacts)
    case .artifactDocument:
        state.reduce(.openArtifacts)
        state.reduce(.artifacts(.open("garden")))
    case .code: state.reduce(.openCode)
    case .codeNewSession:
        state.reduce(.openCode)
        state.reduce(.code(.newSession))
    case .dispatch:
        state.reduce(.openDispatch)
        if let requestID = state.dispatch.loadID {
            state.dispatch.finishLoading(DemoHostResponses.dispatchWelcome, requestID: requestID)
        }
    case .projects: state.reduce(.openProjects)
    default:
        if let destination = demoSettingsDestination(for: id) { state.reduce(.settings(.open(destination))) }
    }
}

func demoSettingsDestination(for id: DemoScreen) -> ClaudeSettingsDestination? {
    switch id {
    case .settingsProfile: .profile
    case .settingsNotifications: .notifications
    case .settingsTimeAndFocus: .timeAndFocus
    case .settingsPrivacy: .privacy
    case .settingsUsage: .usage
    case .settingsBilling: .billing
    case .settingsSharedLinks: .sharedLinks
    case .settingsCapabilities: .capabilities
    case .settingsMemoryFiles: .memoryFiles
    case .settingsCode: .code
    case .settingsConnectors: .connectors
    default: nil
    }
}

/// Hosts `ClaudeSessionView` like the demo does and optionally presents one sheet over it, the same plain
/// `.sheet` presentation the session view uses for its own sheets.
struct SessionHost: View {
    @State var state: SessionState
    let sheet: ((Binding<SessionState>) -> AnyView)?

    init(state: SessionState, sheet: ((Binding<SessionState>) -> AnyView)?) {
        _state = State(initialValue: state)
        self.sheet = sheet
    }

    var body: some View {
        ClaudeSessionView(state: $state, mediaContent: demoMediaContent) { state.reduce($0) }
            .sheet(isPresented: .constant(sheet != nil)) { sheet?($state) }
    }
}
