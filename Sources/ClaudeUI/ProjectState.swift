import Foundation

public struct ClaudeProject: Identifiable, Equatable, Sendable {
    public var id: UUID
    public var name: String
    public var goal: String
    public var icon: String
    public var pinned = false
    public var owned = true
    public var archived = false
    public init(id: UUID = UUID(), name: String, goal: String = "", icon: String = "rectangle.stack") {
        self.id = id
        self.name = name
        self.goal = goal
        self.icon = icon
    }
}
public struct ProjectDraft: Equatable, Sendable {
    public var name = ""
    public var goal = ""
    public var icon = "rectangle.stack"
    public var iconColor = "Default"
    public var context: [String] = []
    public var environment: String?
    public init() {}
}
public enum ProjectFilter: String, CaseIterable, Sendable { case pinned = "Pinned", yours = "Yours" }
public enum ProjectEditor: Equatable, Sendable { case introduction, setup }
public enum ProjectAction: Equatable, Sendable {
    case begin, continueIntroduction, cancel, selectFilter(ProjectFilter), openArchived
    case editName(String), editGoal(String), selectIcon(String), selectIconColor(String)
    case addContext(String), removeContext(String), selectEnvironment(String)
    case openIconPicker, openContext, openContextSource(String), openEnvironment, openFilter, openProject(UUID)
    case create(ProjectDraft)
}
/// Presentation state only. Creation requests leave the draft intact until the host acknowledges them.
public struct ProjectState: Equatable, Sendable {
    public var projects: [ClaudeProject] = []
    public private(set) var filter: ProjectFilter = .yours
    public var visibleProjects: [ClaudeProject] {
        projects.filter { !$0.archived && (filter == .pinned ? $0.pinned : $0.owned) }
    }
    public var suggestedRepository = "example/garden-plan"
    public var environments: [String] = ["Cloud", "Default"]
    public private(set) var editor: ProjectEditor?
    public private(set) var hasSeenIntroduction = false
    public private(set) var draft = ProjectDraft()
    public static let iconColors = [
        "Default", "Gray", "Coral", "Orange", "Gold", "Green", "Teal", "Blue", "Purple", "Pink", "Dark gray", "Red",
        "Dark orange", "Ochre", "Dark green", "Dark teal", "Dark blue", "Violet", "Magenta"
    ]
    public init() {}
    public var canCreate: Bool {
        editor == .setup && !draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    public var validatedDraft: ProjectDraft? {
        guard canCreate else { return nil }
        var value = draft
        value.name = value.name.trimmingCharacters(in: .whitespacesAndNewlines)
        value.goal = value.goal.trimmingCharacters(in: .whitespacesAndNewlines)
        return value
    }
    public mutating func reduce(_ action: ProjectAction) {
        switch action {
        case .selectFilter(let value): filter = value
        case .begin:
            guard editor == nil else { return }
            draft = ProjectDraft()
            editor = hasSeenIntroduction ? .setup : .introduction
        case .continueIntroduction:
            guard editor == .introduction else { return }
            hasSeenIntroduction = true
            editor = .setup
        case .cancel:
            draft = ProjectDraft()
            editor = nil
        case .editName(let value):
            guard editor == .setup else { return }
            draft.name = value
        case .editGoal(let value):
            guard editor == .setup else { return }
            draft.goal = value
        case .selectIcon(let value):
            guard editor == .setup, ProjectIconOption.options.contains(where: { $0.symbol == value }) else { return }
            draft.icon = value
        case .selectIconColor(let value):
            guard editor == .setup, Self.iconColors.contains(value) else { return }
            draft.iconColor = value
        case .addContext(let value):
            guard editor == .setup, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                !draft.context.contains(value)
            else { return }
            draft.context.append(value)
        case .removeContext(let value):
            guard editor == .setup else { return }
            draft.context.removeAll { $0 == value }
        case .selectEnvironment(let value):
            guard editor == .setup, environments.contains(value) else { return }
            draft.environment = value
        case .openArchived, .openIconPicker, .openContext, .openContextSource, .openEnvironment, .openFilter,
            .openProject, .create:
            break
        }
    }
    /// Hosts call this only after accepting a creation request; no service call is made here.
    public mutating func acknowledgeCreated(_ project: ClaudeProject) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
        } else {
            projects.append(project)
        }
        draft = ProjectDraft()
        editor = nil
    }
}

public struct ProjectIconOption: Identifiable, Equatable, Sendable {
    public let symbol: String
    public let name: String
    public var id: String { symbol }
    public static let options: [Self] = [
        ("rectangle.stack", "Project"), ("folder", "Folder"), ("chevron.left.forwardslash.chevron.right", "Code"),
        ("externaldrive", "Database"), ("brain", "Brain"), ("flask", "Science"), ("wrench", "Wrench"),
        ("chart.xyaxis.line", "Chart"), ("chart.bar", "Bars"), ("person.3", "Team"), ("person.2", "People"),
        ("book", "Book"), ("shippingbox", "Package"), ("note.text", "Note"),
        ("doc.text", "Document"), ("lightbulb", "Idea"), ("paintpalette", "Art"), ("star", "Star"), ("flag", "Flag"),
        ("house", "Home"), ("sun.max", "Sun"),
        ("clock", "Clock"), ("calendar", "Calendar"), ("scroll", "Scroll"), ("moon", "Moon"), ("moon.stars", "Night"),
        ("sun.horizon", "Sunrise"), ("leaf", "Nature"),
        ("atom", "Atom"), ("waveform.path", "DNA"), ("globe.europe.africa", "Planet"), ("globe", "Globe"),
        ("cloud", "Cloud"), ("hammer", "Build"), ("key", "Key"),
        ("lock", "Lock"), ("camera", "Camera"), ("mic", "Microphone"), ("cup.and.saucer", "Coffee"), ("gift", "Gift"),
        ("theatermask.and.paintbrush", "Ghost"), ("graduationcap", "Education"),
        ("books.vertical", "Library"), ("tablecells", "Table"), ("rectangle.on.rectangle", "Windows"),
        ("checklist", "Checklist"), ("list.clipboard", "Clipboard"), ("photo", "Image"), ("bookmark", "Bookmark"),
        ("building.columns", "Institution"), ("signpost.right.and.left", "Directions"), ("mappin", "Location"),
        ("envelope", "Mail"), ("heart", "Heart"), ("bolt", "Energy"), ("square.on.circle", "Shapes"),
        ("ear", "Listen"), ("scalemass", "Balance"), ("eye", "Eye"), ("binoculars", "Explore"),
        ("megaphone", "Announcement"), ("paperplane", "Send"), ("chart.line.uptrend.xyaxis", "Growth"),
        ("stopwatch", "Timer"), ("display", "Desktop"), ("book.closed", "Journal"), ("keyboard", "Keyboard"),
        ("iphone", "Phone"), ("phone", "Call"), ("square.grid.3x3", "Grid")
    ].map { Self(symbol: $0.0, name: $0.1) }
    public static func matching(_ query: String) -> [Self] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return options.filter {
            query.isEmpty || $0.name.localizedCaseInsensitiveContains(query)
                || $0.symbol.localizedCaseInsensitiveContains(query)
        }
    }
}
