import Foundation

/// Metadata only. The host supplies pixels through ClaudeSessionView's mediaContent closure.
public enum ClaudeMediaKind: Equatable, Sendable { case image, video }

public struct ClaudeMedia: Identifiable, Equatable, Sendable {
    public var id: String
    public var fileName: String
    public var accessibilityDescription: String
    public var kind: ClaudeMediaKind
    public var aspectRatio: Double
    public init(
        id: String, fileName: String, accessibilityDescription: String = "Photo", aspectRatio: Double = 1,
        kind: ClaudeMediaKind = .image
    ) {
        self.kind = kind
        self.id = id
        self.fileName = fileName
        self.accessibilityDescription = accessibilityDescription
        self.aspectRatio = aspectRatio.isFinite && aspectRatio > 0 ? aspectRatio : 1
    }
    public var fileExtension: String { (fileName as NSString).pathExtension.uppercased() }
    public var fileStem: String { (fileName as NSString).deletingPathExtension }
    public var displayAspectRatio: Double { aspectRatio.isFinite && aspectRatio > 0 ? aspectRatio : 1 }
}
public enum ClaudeMediaAction: Equatable, Sendable {
    case beginSelection, toggleRecent(String), attachSelected, cancelSelection
    case removeDraft(String), open(ClaudeMedia), close, toggleControls
    case requestPhotos, copyFileName(ClaudeMedia), edit(ClaudeMedia), share(ClaudeMedia), download(ClaudeMedia)
    case videoViewerAppeared(ClaudeMedia), videoViewerDisappeared(ClaudeMedia)
}
public struct ClaudeMediaState: Equatable, Sendable {
    public var recent: [ClaudeMedia] = []
    public var draft: [ClaudeMedia] = []
    public private(set) var selectedIDs: [String] = []
    public private(set) var viewer: ClaudeMedia?
    public private(set) var controlsVisible = true
    public init() {}
    public var selected: [ClaudeMedia] { selectedIDs.compactMap { id in recent.first(where: { $0.id == id }) } }
    public mutating func reduce(_ action: ClaudeMediaAction) {
        switch action {
        case .beginSelection, .cancelSelection: selectedIDs = []
        case .toggleRecent(let id):
            guard recent.contains(where: { $0.id == id }) else { return }
            if selectedIDs.contains(id) { selectedIDs.removeAll { $0 == id } } else { selectedIDs.append(id) }
        case .attachSelected:
            for item in selected where !draft.contains(where: { $0.id == item.id }) { draft.append(item) }
            selectedIDs = []
        case .removeDraft(let id):
            draft.removeAll { $0.id == id }
            if viewer?.id == id { viewer = nil }
        case .open(let item):
            viewer = item
            controlsVisible = true
        case .close:
            viewer = nil
            controlsVisible = true
        case .toggleControls: if viewer?.kind == .image { controlsVisible.toggle() }
        case .requestPhotos, .copyFileName, .edit, .share, .download, .videoViewerAppeared, .videoViewerDisappeared:
            break
        }
    }
}
