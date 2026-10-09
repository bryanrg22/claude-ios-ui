import Foundation

public enum ArtifactOwnership: String, CaseIterable, Sendable {
    case all = "All", pinned = "Pinned", yours = "Yours", shared = "Shared with you"
}
public enum ArtifactKind: String, CaseIterable, Sendable {
    case all = "All types", design = "Design", designSystem = "Design System", docs = "Docs", slides = "Slides", other =
        "Other"
}
public struct ArtifactSection: Identifiable, Equatable, Sendable {
    public var id: String
    public var title: String
    /// Markdown-compatible text interpreted only by the local SwiftUI renderer.
    public var paragraphs: [String]
    public init(id: String, title: String, paragraphs: [String]) {
        self.id = id
        self.title = title
        self.paragraphs = paragraphs
    }
}
public struct ArtifactDocument: Equatable, Sendable {
    public var title: String
    public var date: String
    public var author: String
    public var tab: String
    public var sections: [ArtifactSection]
    public init(
        title: String, date: String = "", author: String = "", tab: String = "Tab 1", sections: [ArtifactSection] = []
    ) {
        self.title = title
        self.date = date
        self.author = author
        self.tab = tab
        self.sections = sections
    }
}
public struct ClaudeArtifact: Identifiable, Equatable, Sendable {
    public var id: String
    public var title: String
    public var kind: ArtifactKind
    public var edited: String
    public var privacy: String
    public var pinned: Bool
    public var owned: Bool
    public var darkPreview: Bool
    public var document: ArtifactDocument?
    public var canUndo: Bool
    public var canRedo: Bool
    public init(
        id: String, title: String, kind: ArtifactKind = .docs, edited: String = "", privacy: String = "Only you",
        pinned: Bool = false, owned: Bool = true, darkPreview: Bool = false, document: ArtifactDocument? = nil,
        canUndo: Bool = false, canRedo: Bool = false
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.edited = edited
        self.privacy = privacy
        self.pinned = pinned
        self.owned = owned
        self.darkPreview = darkPreview
        self.document = document
        self.canUndo = canUndo
        self.canRedo = canRedo
    }
}
public enum ArtifactAction: Equatable, Sendable {
    case ownership(ArtifactOwnership), kind(ArtifactKind), search(String), open(String), close, toggleTitle,
        toggleSection(String)
    case markdown(MarkdownAction)
    case share(String), comments(String), tabs(String), undo(String), redo(String)
}
/// Presentation only: no remote documents, permissions or edit history are modified.
public struct ArtifactsState: Equatable, Sendable {
    public var items: [ClaudeArtifact] = []
    public var query = ""
    public private(set) var ownership: ArtifactOwnership = .all
    public private(set) var kind: ArtifactKind = .all
    public private(set) var selectedID: String?
    public private(set) var titleCollapsed = false
    public private(set) var collapsedSections: Set<String> = []
    public init() {}
    public var selected: ClaudeArtifact? { items.first { $0.id == selectedID } }
    public var visibleItems: [ClaudeArtifact] {
        items.filter { item in
            let ownerMatches =
                ownership == .all || (ownership == .pinned && item.pinned) || (ownership == .yours && item.owned)
                || (ownership == .shared && !item.owned)
            return ownerMatches && (kind == .all || item.kind == kind)
                && (query.isEmpty || item.title.localizedCaseInsensitiveContains(query))
        }
    }
    public mutating func reduce(_ action: ArtifactAction) {
        switch action {
        case .ownership(let value): ownership = value
        case .kind(let value): kind = value
        case .search(let value): query = value
        case .open(let id):
            guard items.contains(where: { $0.id == id && $0.document != nil }) else { return }
            selectedID = id
            titleCollapsed = false
            collapsedSections = []
        case .close:
            selectedID = nil
            titleCollapsed = false
            collapsedSections = []
        case .toggleTitle:
            guard selected?.document != nil else { return }
            titleCollapsed.toggle()
        case .toggleSection(let id):
            guard selected?.document?.sections.contains(where: { $0.id == id }) == true else { return }
            if !collapsedSections.insert(id).inserted { collapsedSections.remove(id) }
        default: break
        }
    }
}
