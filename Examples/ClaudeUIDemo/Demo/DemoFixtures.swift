import ClaudeUI
import SwiftUI

/// Offline pixels for the demo's media descriptors: a synthetic photo, and a silent generated clip in the video viewer.
func demoMediaContent(_ item: ClaudeMedia, _ presentation: ClaudeMediaPresentation) -> AnyView {
    if item.kind == .video, presentation == .videoViewer { return AnyView(DemoVideo()) }
    return AnyView(DemoPhoto(item: item))
}

extension SessionState {
    /// Installs the demo's fictional connectors, Code data, projects, artifacts and settings.
    /// The demo app and the screenshot tests share this so both show the same content.
    mutating func installDemoFixtures() {
        self.settings.connectors = .init(
            discovery: true,
            connectors: [
                .init(
                    id: "design", name: "Design Studio", symbol: "square.stack.3d.up", connected: true,
                    tools: [
                        .init(id: "mapping", name: "Add component documentation mapping", permission: .blocked),
                        .init(id: "create", name: "Create design", permission: .approval),
                        .init(id: "export", name: "Export preview", permission: .blocked)
                    ]),
                .init(
                    id: "calendar", name: "Calendar", symbol: "calendar", connected: true,
                    tools: [.init(id: "events", name: "List events", permission: .approval)]),
                .init(id: "notes", name: "Notes", symbol: "note.text", connected: false),
                .init(id: "travel", name: "Travel Planner", symbol: "airplane", connected: false)
            ],
            toolDescriptions: ["design": ["create": "Create a design using the host-provided workspace and content."]])
        self.settings.connectors.catalog = .init(
            items: [
                .init(
                    id: "files", name: "Cloud Files", symbol: "folder", subtitle: "Most popular",
                    detail: "Search, read, and upload files instantly", categories: ["Communication"], connected: true,
                    ranks: [.popular: 1]),
                .init(
                    id: "mail", name: "Mail", symbol: "envelope", subtitle: "#2 popular",
                    detail: "Draft replies, summarize threads, & search your inbox", categories: ["Communication"],
                    connected: true, ranks: [.popular: 2]),
                .init(
                    id: "calendar", name: "Calendar", symbol: "calendar", subtitle: "#3 popular",
                    detail: "Manage your schedule and coordinate meetings effortlessly", categories: ["Communication"],
                    connected: true),
                .init(
                    id: "design", name: "Design Studio", symbol: "square.stack.3d.up", subtitle: "#4 popular",
                    detail: "Search, create, autofill, and export designs", categories: ["Creative"], interactive: true),
                .init(
                    id: "notes", name: "Notes", symbol: "note.text", subtitle: "#5 popular",
                    detail: "Connect your workspace to search, update, and power workflows across tools",
                    categories: ["Creative"]),
                .init(
                    id: "research", name: "Health Library", symbol: "books.vertical", subtitle: "#32 popular",
                    detail: "Search public biomedical literature", categories: ["Consumer health"]),
                .init(
                    id: "trails", name: "Trail Guide", symbol: "mountain.2", subtitle: "#37 popular",
                    detail: "Find your next hike", categories: ["Consumer health"], interactive: true)
            ],
            categories: [
                "Commerce & shopping", "Communication", "Consumer health", "Creative", "Data & analytics",
                "Development tools"
            ], organizationLabel: "Example Organization")
        self.settings.capabilities = .init(
            values: Dictionary(
                uniqueKeysWithValues: ClaudeCapability.allCases.map { key in
                    (
                        key,
                        .init(
                            isEnabled: key != .sensitiveMemory, isEditable: key != .artifacts,
                            dependencyLabel: key == .artifacts ? "Required by code execution" : nil)
                    )
                }))
        self.settings.memoryFiles = .init(groups: [
            .init(
                id: "you", title: "You",
                files: [
                    .init(
                        id: "profile", title: "Profile", updatedLabel: "Updated 2 days ago",
                        summary: "A short profile supplied by the host.",
                        markdown: "Enjoys learning about design and gardening.")
                ]),
            .init(
                id: "topics", title: "Topics",
                files: [
                    .init(
                        id: "coding", title: "Coding Style", updatedLabel: "Updated last month",
                        summary: "Preferences for clear, maintainable examples",
                        markdown:
                            "- Use descriptive names for variables and functions.\n- Keep examples small enough to understand in one sitting.\n- Explain the purpose of a change before showing the implementation.\n- Prefer `let` when a value does not change.\n- Include a small example that demonstrates the expected result."
                    ),
                    .init(
                        id: "garden", title: "Gardening", updatedLabel: "Updated 3 weeks ago",
                        summary: "Notes about a balcony garden",
                        markdown:
                            "- Uses a few containers for herbs.\n- Prefers plants that suit the available sunlight."),
                    .init(
                        id: "reading", title: "Reading", updatedLabel: "Updated 2 months ago",
                        markdown: "Enjoys short stories and illustrated books.")
                ])
        ])
        self.settings.codePreferences = .init(transcriptFont: .anthropicSans)
        self.settings.billing = .init(planLabel: "Max", origin: .website)
        let sharedMessages: [ChatMessage] = [
            .init(role: .user, text: "Help me plan a small balcony garden."),
            .init(
                role: .assistant,
                text:
                    "Start with the light your balcony gets each day. A few carefully chosen containers can make the space feel inviting.\n\n### A simple starting plan\n\n- Choose two herbs you already enjoy cooking with.\n- Use containers with drainage holes.\n- Leave room to move comfortably.\n\nObserve the plants for the first week and adjust watering to the weather."
            )
        ]
        self.settings.sharedLinks = .init(groups: [
            .init(
                id: "september", title: "September",
                snapshots: [
                    .init(
                        id: "garden", title: "Planning a small balcony garden and choosing herbs",
                        sharedLabel: "Shared 1 week ago", byline: "Shared by Jordan 1 week ago",
                        messages: sharedMessages),
                    .init(
                        id: "reading", title: "Building a weekend reading list", sharedLabel: "Shared 1 month ago",
                        byline: "Shared by Jordan 1 month ago", messages: sharedMessages)
                ]),
            .init(
                id: "may", title: "May",
                snapshots: [
                    .init(
                        id: "walk", title: "Finding time for a neighborhood walk", sharedLabel: "Shared 4 months ago",
                        byline: "Shared by Jordan 4 months ago", messages: sharedMessages)
                ]),
            .init(
                id: "april", title: "April",
                snapshots: [
                    .init(
                        id: "notes", title: "Organizing notes for a creative project",
                        sharedLabel: "Shared 6 months ago", byline: "Shared by Jordan 6 months ago",
                        messages: sharedMessages)
                ])
        ])
        self.settings.usage = .init(
            currentSession: .init(
                id: "current", title: "Current session", usedPercentage: 12, resetLabel: "Resets in 3 hr 20 min"),
            weekly: [
                .init(id: "all", title: "All models", usedPercentage: 27, resetLabel: "Resets Mon 9:00 AM"),
                .init(id: "fable", title: "Fable only", usedPercentage: 40, resetLabel: "Resets Mon 9:00 AM")
            ], balanceLabel: "18 credits",
            credits: [
                .init(
                    id: "promo", title: "Promo credit", subtitle: "35% used · Expires Jun 15, 2027",
                    badge: "+20 credits", usedPercentage: 35),
                .init(id: "purchase-a", title: "Purchase - Sep 12, 2026", badge: "+3 credits", usedPercentage: 5),
                .init(id: "purchase-b", title: "Purchase - Aug 20, 2026", badge: "+2 credits", usedPercentage: 0)
            ])
        self.settings.privacy = .init(allowsModelImprovement: true)
        self.settings.notifications = .init(enabled: Set(ClaudeNotificationPreference.allCases))
        self.settings.versionLabel = "Claude UI Demo 1.0"
        self.settings.account = .init(email: "jordan@example.com", planLabel: "Max plan")
        self.settings.profile = .init(initials: "JL", fullName: "Jordan Lee", nickname: "Jordan")
        self.media.recent = (1...3).map {
            .init(
                id: "garden-\($0)", fileName: "Garden-\($0).png", accessibilityDescription: "Garden illustration \($0)",
                aspectRatio: 0.97)
        }
        self.devices.rows = [.init(id: "sample-desktop", name: "Claude Desktop (macOS)", status: .connected)]
        self.dispatch.connection = .online
        self.code.sessions = [
            .init(
                id: "design", title: "Design study to website translation", detail: "sample-website · main",
                status: .working, location: .connectedComputer),
            .init(id: "portfolio", title: "Community portfolio website", detail: "2d", location: .unavailableComputer),
            .init(
                id: "map", title: "Walking route map", detail: "Waiting for you · 2d", status: .needsInput,
                location: .unavailableComputer),
            .init(
                id: "assets", title: "Portfolio assets deliverable", detail: "Sep 29", location: .unavailableComputer),
            .init(
                id: "impact", title: "Evaluate project fit for community events",
                detail: "Waiting for you · Sample-Project", status: .needsInput, location: .cloud),
            .init(id: "brief", title: "Community case study brief", detail: "Sample-Project", location: .cloud),
            .init(
                id: "camera", title: "Camera preview controls", detail: "Waiting for you · Sep 19", status: .needsInput,
                location: .unavailableComputer),
            .init(
                id: "performance", title: "Computer performance study", detail: "Sep 4", location: .unavailableComputer),
            .init(
                id: "review", title: "Typography review", detail: "Ready for review · Sep 3", status: .readyForReview,
                location: .cloud),
            .init(
                id: "completed", title: "Sample documentation", detail: "Sep 2", status: .completed, location: .cloud),
            .init(
                id: "archived", title: "Archived sample project", detail: "Aug 30", status: .completed,
                location: .cloud, archived: true)
        ]
        let sampleDocument = ArtifactDocument(
            title: "Community Garden Plan — Jordan", date: "Oct 6, 2026", author: "Jordan Lee",
            sections: [
                .init(
                    id: "overview", title: "A shared place to grow",
                    paragraphs: [
                        "A neighborhood garden gives people a place to learn together, share seasonal produce, and enjoy a quiet afternoon outside.",
                        "The first workshop introduces the site, the planting calendar, and simple ways to get involved. Everyone is welcome, including first-time gardeners.",
                        "**A practical first step:** Start with a small herb bed near the entrance. Label each plant clearly and leave room for a bench and an accessible path.",
                        "Three ideas for the first season:",
                        "1. **Grow something familiar.** Ask neighbors which herbs and vegetables they use most often.",
                        "2. **Share the work.** Keep a simple weekly watering schedule."
                    ]),
                .init(
                    id: "next", title: "Next steps",
                    paragraphs: [
                        "Sketch the beds, choose a date for the first gathering, and prepare a list of shared supplies."
                    ])
            ])
        self.artifacts.items = [
            .init(
                id: "garden", title: sampleDocument.title, edited: "Edited yesterday", pinned: true,
                document: sampleDocument),
            .init(
                id: "workshop", title: "Neighborhood Workshop — Planning Notes", edited: "Edited 2 days ago",
                document: .init(
                    title: "Neighborhood Workshop", date: "Oct 5, 2026",
                    sections: [
                        .init(
                            id: "plan", title: "Preparing the space",
                            paragraphs: ["Arrange chairs around the shared table and set out the sample materials."])
                    ])),
            .init(
                id: "library", title: "Community Library — Volunteer Guide", edited: "Edited 2 days ago",
                document: .init(title: "Community Library — Volunteer Guide")),
            .init(
                id: "walk", title: "Weekend Walk — Route Planning", edited: "Edited 2 days ago",
                document: .init(title: "Weekend Walk — Route Planning")),
            .init(
                id: "design", title: "Community bulletin board design study", kind: .design, edited: "Edited last wk.",
                darkPreview: true),
            .init(
                id: "materials", title: "Workshop Materials — An Overview", edited: "Edited 3 wk. ago",
                document: .init(title: "Workshop Materials — An Overview")),
            .init(
                id: "welcome", title: "Welcome presentation", kind: .slides, edited: "Edited last mo.",
                privacy: "Shared with you", owned: false)
        ]
        self.code.draft.connectors.discovery = true
        self.code.draft.connectors.connectors = [
            .init(
                id: "design", name: "Design tools", symbol: "paintpalette", connected: true,
                tools: [
                    .init(id: "map", name: "Add Component Mapping", permission: .blocked),
                    .init(id: "plugin", name: "Create Generative Plugin"),
                    .init(id: "file", name: "Create New File", permission: .blocked),
                    .init(id: "shader", name: "Create Shader"),
                    .init(id: "assets", name: "Download Assets", permission: .blocked)
                ]),
            .init(
                id: "mail", name: "Mail", symbol: "envelope", connected: true,
                tools: [.init(id: "search", name: "Search messages")]),
            .init(
                id: "calendar", name: "Calendar", symbol: "calendar", connected: true,
                tools: [.init(id: "events", name: "List events")]),
            .init(
                id: "files", name: "Files", symbol: "folder", connected: true,
                tools: [.init(id: "list", name: "List files")]),
            .init(id: "travel", name: "Travel", symbol: "suitcase")
        ]
        self.code.draft.greetingName = "Jordan"
        self.code.draft.repositories = [
            .init(id: "sample", name: "SampleProject", owner: "sample-org"),
            .init(id: "library", name: "BookLibrary", owner: "demo-team"),
            .init(id: "calendar", name: "Community-Calendar", owner: "jordan-example"),
            .init(id: "automation", name: "Sample-Automation", owner: "jordan-example"),
            .init(id: "api", name: "api-lab", owner: "jordan-example"),
            .init(id: "design", name: "Design-Study", owner: "jordan-example"),
            .init(id: "notes", name: "Field-Notes", owner: "jordan-example")
        ]
        self.code.draft.repository = self.code.draft.repositories[0]
        self.code.draft.environments = [.init(id: "cloud", name: "Cloud"), .init(id: "default", name: "Default")]
        self.code.draft.selectedEnvironmentID = "default"
        self.code.draft.branchesByRepository = [
            "sample": [.init(id: "main", name: "main", isDefault: true), .init(id: "feature", name: "sample_branch")]
        ]
    }
}

/// Simulated backend replies the demo delivers after a short delay.
enum DemoHostResponses {
    static let dispatchWelcome: [DispatchMessage] = [
        .init(
            text:
                "Hey, glad you’re here. Tell me what’s on your plate, no ask is too big or small. You could ask me to:\n\n• Find a confirmation in Downloads and check the order status on the site.\n\n• Open a GitHub project on your computer, make a quick code change, and run the tests.\n\n• Scan Slack for a bug report, find the file, and open a Code session to fix it.\n\n• Search your repos for an error message and trace where it comes from.\n\nYou can also control this conversation from your phone. Download the Claude app for iOS or Android, then go to the Dispatch tab.",
            timestamp: "Oct 7, 2026 at 9:11 PM")
    ]

    static let accountProfile = DeviceAccountProfile(
        initials: "JL", fullName: "Jordan Lee", nickname: "Jordan", work: "Engineering",
        workChoices: ["Engineering"], organizationID: "00000000-0000-4000-8000-000000000001",
        deletionUnavailableReason:
            "To delete your account, please cancel your Claude Max subscription first.")
}
