import SwiftUI
import ClaudeUI
import ClaudeWidgets
import WidgetKit

@main
struct ClaudeDemoApp: App {
    @State private var widgetPreview = ProcessInfo.processInfo.arguments.contains("--widgets")
    @State private var widgetCamera = false
    @State private var announcement = ProcessInfo.processInfo.arguments.contains("--announcement")
    @State private var configured = false
    @State private var state = SessionState()
    @State private var dispatchTask: Task<Void, Never>?
    @State private var accountTask: Task<Void, Never>?
    @State private var responseTask: Task<Void, Never>?
    var body: some Scene {
        WindowGroup {
            Group {
                if let screen = DemoScreen(launchArguments: ProcessInfo.processInfo.arguments) {
                    DemoScreenView(
                        screen: screen,
                        appearance: ProcessInfo.processInfo.arguments.contains("--light") ? .light : .dark)
                } else if widgetPreview {
                    WidgetPreview().environment(
                        \.openURL,
                        OpenURLAction { url in
                            routeWidget(url)
                            return .handled
                        })
                } else {
                    ClaudeSessionView(
                        state: $state,
                        mediaContent: demoMediaContent, onAction: handle)
                }
            }
            .onAppear {
                if !configured {
                    configureFixture()
                    configured = true
                }
            }
            .onOpenURL(perform: routeWidget)
            .sheet(isPresented: $announcement) {
                ClaudeWorkAnnouncementView(onDismiss: { announcement = false }) { ClaudeWorkAnnouncementStill() }
                    .presentationDetents([.large]).presentationCornerRadius(40).presentationDragIndicator(.hidden)
            }
            .fullScreenCover(isPresented: $widgetCamera) {
                ClaudeCameraView(onCancel: { widgetCamera = false }, onCapture: { _ in widgetCamera = false }) {
                    LinearGradient(colors: [.gray, .black], startPoint: .top, endPoint: .bottom)
                }
            }
        }
    }
    private func routeWidget(_ url: URL) {
        guard let destination = ClaudeWidgetDestination(url: url) else { return }
        widgetPreview = false
        switch destination {
        case .chat: handle(.newSession)
        case .camera: widgetCamera = true
        case .voice:
            handle(.newSession)
            handle(.startVoice)
        case .code: handle(.openCode)
        case .dispatch: handle(.openDispatch)
        case .newCodeSession:
            handle(.openCode)
            handle(.code(.newSession))
        case .searchCode:
            handle(.openCode)
            handle(.code(.search))
        }
    }
    private func configureFixture() {
        WidgetCenter.shared.reloadAllTimelines()
        state.installDemoFixtures()
        let args = ProcessInfo.processInfo.arguments
        if args.contains("--video") {
            state.media.draft = [
                .init(
                    id: "garden-video", fileName: "Garden-Motion.mp4", accessibilityDescription: "Garden motion video",
                    aspectRatio: 240.0 / 426, kind: .video)
            ]
        }
        if args.contains("--markdown") { state.messages = [.init(role: .assistant, text: MarkdownFixture.source)] }
        if args.contains("--light") { state.appearance = .light }
        if args.contains("--typed") { state.draft = "Reply with a short greeting." }
        if args.contains("--complete") {
            state.messages = [
                .init(role: .user, text: "Reply with a short greeting."),
                .init(role: .assistant, text: "Hey Jordan! What's on your mind tonight?")
            ]
        }
        if args.contains("--editing"), let message = state.messages.first { state.reduce(.beginEditing(message.id)) }
        if args.contains("--dictation") { state.reduce(.startDictation) }
        if args.contains("--waveform") {
            state.reduce(.startDictation)
            state.dictationLevels = [0, 0.1, 0.3, 0.8, 1, 0.5, 0.2, 0, 0.4, 0.7, 1, 0.3, 0.1, 0]
        }
        if args.contains("--artifacts") { handle(.openArtifacts) }
        if args.contains("--artifact-document") {
            handle(.openArtifacts)
            handle(.artifacts(.open("garden")))
        }
        if args.contains("--code") { handle(.openCode) }
        if args.contains("--code-new-session") {
            handle(.openCode)
            handle(.code(.newSession))
        }
        if args.contains("--dispatch") { handle(.openDispatch) }
        if args.contains("--voice") { state.reduce(.startVoice) }
        if args.contains("--long-draft") {
            state.draft = String(repeating: "A thoughtful interface makes room for the details. ", count: 32)
        }
    }
    private func handle(_ action: ClaudeAction) {
        if action == .stop || action == .newSession {
            responseTask?.cancel()
            responseTask = nil
        }
        state.reduce(action)
        switch action {
        case .send, .retry:
            guard let responseID = state.responseID else { return }
            responseTask?.cancel()
            responseTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(800))
                let response = "Hey Jordan! What's on your mind tonight?"
                for word in response.split(separator: " ") {
                    guard !Task.isCancelled else { return }
                    state.appendResponse(
                        (state.messages.last?.role == .assistant ? " " : "") + word, responseID: responseID)
                    try? await Task.sleep(for: .milliseconds(140))
                }
                guard !Task.isCancelled else { return }
                state.finishResponse(responseID: responseID)
            }
        case .openDispatch, .dispatch(.reload):
            guard let requestID = state.dispatch.loadID else { return }
            dispatchTask?.cancel()
            dispatchTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(500))
                guard !Task.isCancelled else { return }
                state.dispatch.finishLoading(DemoHostResponses.dispatchWelcome, requestID: requestID)
            }
        case .devices(.openManage):
            guard let requestID = state.devices.accountRequestID else { return }
            accountTask?.cancel()
            accountTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(500))
                guard !Task.isCancelled else { return }
                state.devices.finishAccountLoad(DemoHostResponses.accountProfile, requestID: requestID)
            }
        case .devices(.closeManage):
            accountTask?.cancel()
            accountTask = nil
        case .code(.copyRemoteCommand): UIPasteboard.general.string = "claude rc"
        case .devices(.copyOrganizationID): UIPasteboard.general.string = state.devices.profile.organizationID
        case .markdown(_, .copyCode(let text)), .artifacts(.markdown(.copyCode(let text))):
            UIPasteboard.general.string = text
        case .media(.copyFileName(let item)): UIPasteboard.general.string = item.fileName
        case .settings(.memory(.submitInstruction)):
            if ProcessInfo.processInfo.arguments.contains("--memory-clear-after-submit") {
                state.reduce(.settings(.memory(.replaceDraft(""))))
            }
        case .settings(.submitProfile):
            if let submission = state.settings.pendingProfile {
                state.settings.acknowledgeProfile(requestID: submission.id)
            }
        case .copy(let id):
            if let message = state.messages.first(where: { $0.id == id }) { UIPasteboard.general.string = message.text }
        default: break
        }
    }
}

struct DemoPhoto: View {
    let item: ClaudeMedia
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [.init(red: 0.6, green: 0.77, blue: 0.78), .init(red: 0.93, green: 0.87, blue: 0.64)],
                    startPoint: .top, endPoint: .bottom)
                Circle().fill(.white.opacity(0.85)).frame(width: geometry.size.width * 0.18).offset(
                    x: geometry.size.width * 0.23, y: -geometry.size.height * 0.25)
                Ellipse().fill(Color(red: 0.3, green: 0.5, blue: 0.35)).frame(
                    width: geometry.size.width * 1.7, height: geometry.size.height * 0.7
                ).offset(x: -geometry.size.width * 0.25, y: geometry.size.height * 0.4)
                Ellipse().fill(Color(red: 0.17, green: 0.36, blue: 0.24)).frame(
                    width: geometry.size.width * 1.5, height: geometry.size.height * 0.8
                ).offset(x: geometry.size.width * 0.45, y: geometry.size.height * 0.45)
            }.frame(width: geometry.size.width, height: geometry.size.height).clipped()
        }
    }
}
