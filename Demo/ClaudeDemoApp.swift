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
                if widgetPreview { WidgetPreview().environment(\.openURL, OpenURLAction { url in routeWidget(url); return .handled }) }
                else { ClaudeSessionView(state: $state, mediaContent: { item, presentation in
                    if item.kind == .video, presentation == .videoViewer { return AnyView(DemoVideo()) }
                    return AnyView(DemoPhoto(item: item))
                }, onAction: handle) }
            }
                .onAppear { if !configured { configureFixture(); configured = true } }
                .onOpenURL(perform: routeWidget)
                .sheet(isPresented: $announcement) { ClaudeWorkAnnouncementView(onDismiss: { announcement = false }) { ClaudeWorkAnnouncementStill() }.presentationDetents([.large]).presentationCornerRadius(40).presentationDragIndicator(.hidden) }
                .fullScreenCover(isPresented: $widgetCamera) { ClaudeCameraView(onCancel: { widgetCamera = false }, onCapture: { _ in widgetCamera = false }) { LinearGradient(colors: [.gray, .black], startPoint: .top, endPoint: .bottom) } }
        }
    }
    private func routeWidget(_ url: URL) {
        guard let destination = ClaudeWidgetDestination(url: url) else { return }
        widgetPreview = false
        switch destination {
        case .chat: handle(.newSession)
        case .camera: widgetCamera = true
        case .voice: handle(.newSession); handle(.startVoice)
        case .code: handle(.openCode)
        case .dispatch: handle(.openDispatch)
        case .newCodeSession: handle(.openCode); handle(.code(.newSession))
        case .searchCode: handle(.openCode); handle(.code(.search))
        }
    }
    private func configureFixture() {
        WidgetCenter.shared.reloadAllTimelines()
        state.settings.connectors = .init(discovery: true, connectors: [
            .init(id: "design", name: "Design Studio", symbol: "square.stack.3d.up", connected: true, tools: [.init(id: "mapping", name: "Add component documentation mapping", permission: .blocked), .init(id: "create", name: "Create design", permission: .approval), .init(id: "export", name: "Export preview", permission: .blocked)]),
            .init(id: "calendar", name: "Calendar", symbol: "calendar", connected: true, tools: [.init(id: "events", name: "List events", permission: .approval)]),
            .init(id: "notes", name: "Notes", symbol: "note.text", connected: false),
            .init(id: "travel", name: "Travel Planner", symbol: "airplane", connected: false)
        ], toolDescriptions: ["design": ["create": "Create a design using the host-provided workspace and content."]])
        state.settings.connectors.catalog = .init(items: [
            .init(id: "files", name: "Cloud Files", symbol: "folder", subtitle: "Most popular", detail: "Search, read, and upload files instantly", categories: ["Communication"], connected: true, ranks: [.popular: 1]),
            .init(id: "mail", name: "Mail", symbol: "envelope", subtitle: "#2 popular", detail: "Draft replies, summarize threads, & search your inbox", categories: ["Communication"], connected: true, ranks: [.popular: 2]),
            .init(id: "calendar", name: "Calendar", symbol: "calendar", subtitle: "#3 popular", detail: "Manage your schedule and coordinate meetings effortlessly", categories: ["Communication"], connected: true),
            .init(id: "design", name: "Design Studio", symbol: "square.stack.3d.up", subtitle: "#4 popular", detail: "Search, create, autofill, and export designs", categories: ["Creative"], interactive: true),
            .init(id: "notes", name: "Notes", symbol: "note.text", subtitle: "#5 popular", detail: "Connect your workspace to search, update, and power workflows across tools", categories: ["Creative"]),
            .init(id: "research", name: "Health Library", symbol: "books.vertical", subtitle: "#32 popular", detail: "Search public biomedical literature", categories: ["Consumer health"]),
            .init(id: "trails", name: "Trail Guide", symbol: "mountain.2", subtitle: "#37 popular", detail: "Find your next hike", categories: ["Consumer health"], interactive: true)
        ], categories: ["Commerce & shopping", "Communication", "Consumer health", "Creative", "Data & analytics", "Development tools"], organizationLabel: "Example Organization")
        state.settings.capabilities = .init(values: Dictionary(uniqueKeysWithValues: ClaudeCapability.allCases.map { key in (key, .init(isEnabled: key != .sensitiveMemory, isEditable: key != .artifacts, dependencyLabel: key == .artifacts ? "Required by code execution" : nil)) }))
        state.settings.memoryFiles = .init(groups: [
            .init(id: "you", title: "You", files: [.init(id: "profile", title: "Profile", updatedLabel: "Updated 2 days ago", summary: "A short profile supplied by the host.", markdown: "Enjoys learning about design and gardening.")]),
            .init(id: "topics", title: "Topics", files: [
                .init(id: "coding", title: "Coding Style", updatedLabel: "Updated last month", summary: "Preferences for clear, maintainable examples", markdown: "- Use descriptive names for variables and functions.\n- Keep examples small enough to understand in one sitting.\n- Explain the purpose of a change before showing the implementation.\n- Prefer `let` when a value does not change.\n- Include a small example that demonstrates the expected result."),
                .init(id: "garden", title: "Gardening", updatedLabel: "Updated 3 weeks ago", summary: "Notes about a balcony garden", markdown: "- Uses a few containers for herbs.\n- Prefers plants that suit the available sunlight."),
                .init(id: "reading", title: "Reading", updatedLabel: "Updated 2 months ago", markdown: "Enjoys short stories and illustrated books.")])])
        state.settings.codePreferences = .init(transcriptFont: .anthropicSans)
        state.settings.billing = .init(planLabel: "Max", origin: .website)
        let sharedMessages: [ChatMessage] = [.init(role: .user, text: "Help me plan a small balcony garden."), .init(role: .assistant, text: "Start with the light your balcony gets each day. A few carefully chosen containers can make the space feel inviting.\n\n### A simple starting plan\n\n- Choose two herbs you already enjoy cooking with.\n- Use containers with drainage holes.\n- Leave room to move comfortably.\n\nObserve the plants for the first week and adjust watering to the weather.")]
        state.settings.sharedLinks = .init(groups: [
            .init(id: "september", title: "September", snapshots: [.init(id: "garden", title: "Planning a small balcony garden and choosing herbs", sharedLabel: "Shared 1 week ago", byline: "Shared by Jordan 1 week ago", messages: sharedMessages), .init(id: "reading", title: "Building a weekend reading list", sharedLabel: "Shared 1 month ago", byline: "Shared by Jordan 1 month ago", messages: sharedMessages)]),
            .init(id: "may", title: "May", snapshots: [.init(id: "walk", title: "Finding time for a neighborhood walk", sharedLabel: "Shared 4 months ago", byline: "Shared by Jordan 4 months ago", messages: sharedMessages)]),
            .init(id: "april", title: "April", snapshots: [.init(id: "notes", title: "Organizing notes for a creative project", sharedLabel: "Shared 6 months ago", byline: "Shared by Jordan 6 months ago", messages: sharedMessages)])])
        state.settings.usage = .init(currentSession: .init(id: "current", title: "Current session", usedPercentage: 12, resetLabel: "Resets in 3 hr 20 min"), weekly: [.init(id: "all", title: "All models", usedPercentage: 27, resetLabel: "Resets Mon 9:00 AM"), .init(id: "fable", title: "Fable only", usedPercentage: 40, resetLabel: "Resets Mon 9:00 AM")], balanceLabel: "18 credits", credits: [.init(id: "promo", title: "Promo credit", subtitle: "35% used · Expires Jun 15, 2027", badge: "+20 credits", usedPercentage: 35), .init(id: "purchase-a", title: "Purchase - Sep 12, 2026", badge: "+3 credits", usedPercentage: 5), .init(id: "purchase-b", title: "Purchase - Aug 20, 2026", badge: "+2 credits", usedPercentage: 0)])
        state.settings.privacy = .init(allowsModelImprovement: true)
        state.settings.notifications = .init(enabled: Set(ClaudeNotificationPreference.allCases))
        state.settings.versionLabel = "Claude UI Demo 1.0"
        state.settings.account = .init(email: "jordan@example.com", planLabel: "Max plan")
        state.settings.profile = .init(initials: "JL", fullName: "Jordan Lee", nickname: "Jordan")
        state.media.recent = (1...3).map { .init(id: "garden-\($0)", fileName: "Garden-\($0).png", accessibilityDescription: "Garden illustration \($0)", aspectRatio: 0.97) }
        state.devices.rows = [.init(id: "sample-desktop", name: "Claude Desktop (macOS)", status: .connected)]
        state.dispatch.connection = .online
        state.code.sessions = [
            .init(id: "design", title: "Design study to website translation", detail: "sample-website · main", status: .working, location: .connectedComputer),
            .init(id: "portfolio", title: "Community portfolio website", detail: "2d", location: .unavailableComputer),
            .init(id: "map", title: "Walking route map", detail: "Waiting for you · 2d", status: .needsInput, location: .unavailableComputer),
            .init(id: "assets", title: "Portfolio assets deliverable", detail: "Sep 29", location: .unavailableComputer),
            .init(id: "impact", title: "Evaluate project fit for community events", detail: "Waiting for you · Sample-Project", status: .needsInput, location: .cloud),
            .init(id: "brief", title: "Community case study brief", detail: "Sample-Project", location: .cloud),
            .init(id: "camera", title: "Camera preview controls", detail: "Waiting for you · Sep 19", status: .needsInput, location: .unavailableComputer),
            .init(id: "performance", title: "Computer performance study", detail: "Sep 4", location: .unavailableComputer),
            .init(id: "review", title: "Typography review", detail: "Ready for review · Sep 3", status: .readyForReview, location: .cloud),
            .init(id: "completed", title: "Sample documentation", detail: "Sep 2", status: .completed, location: .cloud),
            .init(id: "archived", title: "Archived sample project", detail: "Aug 30", status: .completed, location: .cloud, archived: true)
        ]
        let sampleDocument = ArtifactDocument(title: "Community Garden Plan — Jordan", date: "Oct 6, 2026", author: "Jordan Lee", sections: [
            .init(id: "overview", title: "A shared place to grow", paragraphs: ["A neighborhood garden gives people a place to learn together, share seasonal produce, and enjoy a quiet afternoon outside.", "The first workshop introduces the site, the planting calendar, and simple ways to get involved. Everyone is welcome, including first-time gardeners.", "**A practical first step:** Start with a small herb bed near the entrance. Label each plant clearly and leave room for a bench and an accessible path.", "Three ideas for the first season:", "1. **Grow something familiar.** Ask neighbors which herbs and vegetables they use most often.", "2. **Share the work.** Keep a simple weekly watering schedule."]),
            .init(id: "next", title: "Next steps", paragraphs: ["Sketch the beds, choose a date for the first gathering, and prepare a list of shared supplies."])
        ])
        state.artifacts.items = [
            .init(id: "garden", title: sampleDocument.title, edited: "Edited yesterday", pinned: true, document: sampleDocument),
            .init(id: "workshop", title: "Neighborhood Workshop — Planning Notes", edited: "Edited 2 days ago", document: .init(title: "Neighborhood Workshop", date: "Oct 5, 2026", sections: [.init(id: "plan", title: "Preparing the space", paragraphs: ["Arrange chairs around the shared table and set out the sample materials."])])),
            .init(id: "library", title: "Community Library — Volunteer Guide", edited: "Edited 2 days ago", document: .init(title: "Community Library — Volunteer Guide")),
            .init(id: "walk", title: "Weekend Walk — Route Planning", edited: "Edited 2 days ago", document: .init(title: "Weekend Walk — Route Planning")),
            .init(id: "design", title: "Community bulletin board design study", kind: .design, edited: "Edited last wk.", darkPreview: true),
            .init(id: "materials", title: "Workshop Materials — An Overview", edited: "Edited 3 wk. ago", document: .init(title: "Workshop Materials — An Overview")),
            .init(id: "welcome", title: "Welcome presentation", kind: .slides, edited: "Edited last mo.", privacy: "Shared with you", owned: false)
        ]
        state.code.draft.connectors.discovery = true
        state.code.draft.connectors.connectors = [
            .init(id: "design", name: "Design tools", symbol: "paintpalette", connected: true, tools: [.init(id: "map", name: "Add Component Mapping", permission: .blocked), .init(id: "plugin", name: "Create Generative Plugin"), .init(id: "file", name: "Create New File", permission: .blocked), .init(id: "shader", name: "Create Shader"), .init(id: "assets", name: "Download Assets", permission: .blocked)]),
            .init(id: "mail", name: "Mail", symbol: "envelope", connected: true, tools: [.init(id: "search", name: "Search messages")]),
            .init(id: "calendar", name: "Calendar", symbol: "calendar", connected: true, tools: [.init(id: "events", name: "List events")]),
            .init(id: "files", name: "Files", symbol: "folder", connected: true, tools: [.init(id: "list", name: "List files")]),
            .init(id: "travel", name: "Travel", symbol: "suitcase")
        ]
        state.code.draft.greetingName = "Jordan"
        state.code.draft.repositories = [.init(id: "sample", name: "SampleProject", owner: "sample-org"), .init(id: "library", name: "BookLibrary", owner: "demo-team"), .init(id: "calendar", name: "Community-Calendar", owner: "jordan-example"), .init(id: "automation", name: "Sample-Automation", owner: "jordan-example"), .init(id: "api", name: "api-lab", owner: "jordan-example"), .init(id: "design", name: "Design-Study", owner: "jordan-example"), .init(id: "notes", name: "Field-Notes", owner: "jordan-example")]
        state.code.draft.repository = state.code.draft.repositories[0]
        state.code.draft.environments = [.init(id: "cloud", name: "Cloud"), .init(id: "default", name: "Default")]
        state.code.draft.selectedEnvironmentID = "default"
        state.code.draft.branchesByRepository = ["sample": [.init(id: "main", name: "main", isDefault: true), .init(id: "feature", name: "sample_branch")]]
        let args = ProcessInfo.processInfo.arguments
        if args.contains("--video") { state.media.draft = [.init(id: "garden-video", fileName: "Garden-Motion.mp4", accessibilityDescription: "Garden motion video", aspectRatio: 240.0 / 426, kind: .video)] }
        if args.contains("--markdown") { state.messages = [.init(role: .assistant, text: MarkdownFixture.source)] }
        if args.contains("--light") { state.appearance = .light }
        if args.contains("--typed") { state.draft = "Reply with a short greeting." }
        if args.contains("--complete") { state.messages = [.init(role: .user, text: "Reply with a short greeting."), .init(role: .assistant, text: "Hey Jordan! What's on your mind tonight?")] }
        if args.contains("--editing"), let message = state.messages.first { state.reduce(.beginEditing(message.id)) }
        if args.contains("--dictation") { state.reduce(.startDictation) }
        if args.contains("--waveform") { state.reduce(.startDictation); state.dictationLevels = [0, 0.1, 0.3, 0.8, 1, 0.5, 0.2, 0, 0.4, 0.7, 1, 0.3, 0.1, 0] }
        if args.contains("--artifacts") { handle(.openArtifacts) }
        if args.contains("--artifact-document") { handle(.openArtifacts); handle(.artifacts(.open("garden"))) }
        if args.contains("--code") { handle(.openCode) }
        if args.contains("--code-new-session") { handle(.openCode); handle(.code(.newSession)) }
        if args.contains("--dispatch") { handle(.openDispatch) }
        if args.contains("--voice") { state.reduce(.startVoice) }
        if args.contains("--long-draft") { state.draft = String(repeating: "A thoughtful interface makes room for the details. ", count: 32) }
    }
    private func handle(_ action: ClaudeAction) {
        if action == .stop || action == .newSession { responseTask?.cancel(); responseTask = nil }
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
                    state.appendResponse((state.messages.last?.role == .assistant ? " " : "") + word, responseID: responseID)
                    try? await Task.sleep(for: .milliseconds(140))
                }
                guard !Task.isCancelled else { return }; state.finishResponse(responseID: responseID)
            }
        case .openDispatch, .dispatch(.reload):
            guard let requestID = state.dispatch.loadID else { return }
            dispatchTask?.cancel()
            dispatchTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(500)); guard !Task.isCancelled else { return }
                state.dispatch.finishLoading([.init(text: "Hey, glad you’re here. Tell me what’s on your plate, no ask is too big or small. You could ask me to:\n\n• Find a confirmation in Downloads and check the order status on the site.\n\n• Open a GitHub project on your computer, make a quick code change, and run the tests.\n\n• Scan Slack for a bug report, find the file, and open a Code session to fix it.\n\n• Search your repos for an error message and trace where it comes from.\n\nYou can also control this conversation from your phone. Download the Claude app for iOS or Android, then go to the Dispatch tab.", timestamp: "Oct 7, 2026 at 9:11 PM")], requestID: requestID)
            }
        case .devices(.openManage):
            guard let requestID = state.devices.accountRequestID else { return }
            accountTask?.cancel()
            accountTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(500)); guard !Task.isCancelled else { return }
                state.devices.finishAccountLoad(.init(initials: "JL", fullName: "Jordan Lee", nickname: "Jordan", work: "Engineering", workChoices: ["Engineering"], organizationID: "00000000-0000-4000-8000-000000000001", deletionUnavailableReason: "To delete your account, please cancel your Claude Max subscription first."), requestID: requestID)
            }
        case .devices(.closeManage): accountTask?.cancel(); accountTask = nil
        case .code(.copyRemoteCommand): UIPasteboard.general.string = "claude rc"
        case .devices(.copyOrganizationID): UIPasteboard.general.string = state.devices.profile.organizationID
        case .markdown(_, .copyCode(let text)), .artifacts(.markdown(.copyCode(let text))): UIPasteboard.general.string = text
        case .media(.copyFileName(let item)): UIPasteboard.general.string = item.fileName
        case .settings(.memory(.submitInstruction)):
            if ProcessInfo.processInfo.arguments.contains("--memory-clear-after-submit") { state.reduce(.settings(.memory(.replaceDraft("")))) }
        case .settings(.submitProfile):
            if let submission = state.settings.pendingProfile { state.settings.acknowledgeProfile(requestID: submission.id) }
        case .copy(let id):
            if let message = state.messages.first(where: { $0.id == id }) { UIPasteboard.general.string = message.text }
        default: break
        }
    }
}

private struct DemoPhoto: View {
    let item: ClaudeMedia
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(colors: [.init(red: 0.6, green: 0.77, blue: 0.78), .init(red: 0.93, green: 0.87, blue: 0.64)], startPoint: .top, endPoint: .bottom)
                Circle().fill(.white.opacity(0.85)).frame(width: geometry.size.width * 0.18).offset(x: geometry.size.width * 0.23, y: -geometry.size.height * 0.25)
                Ellipse().fill(Color(red: 0.3, green: 0.5, blue: 0.35)).frame(width: geometry.size.width * 1.7, height: geometry.size.height * 0.7).offset(x: -geometry.size.width * 0.25, y: geometry.size.height * 0.4)
                Ellipse().fill(Color(red: 0.17, green: 0.36, blue: 0.24)).frame(width: geometry.size.width * 1.5, height: geometry.size.height * 0.8).offset(x: geometry.size.width * 0.45, y: geometry.size.height * 0.45)
            }.frame(width: geometry.size.width, height: geometry.size.height).clipped()
        }
    }
}
