import Foundation

public struct ClaudeSharedSnapshot: Identifiable, Equatable, Sendable {
    public let id: String
    public var title: String
    public var sharedLabel: String
    public var byline: String
    public var messages: [ChatMessage]
    public init(id: String, title: String, sharedLabel: String, byline: String, messages: [ChatMessage] = []) {
        self.id = id; self.title = title; self.sharedLabel = sharedLabel; self.byline = byline; self.messages = messages
    }
}
public struct ClaudeSharedLinkGroup: Identifiable, Equatable, Sendable {
    public let id: String
    public var title: String
    public var snapshots: [ClaudeSharedSnapshot]
    public init(id: String, title: String, snapshots: [ClaudeSharedSnapshot]) { self.id = id; self.title = title; self.snapshots = snapshots }
}
public enum ClaudeSharedLinksAction: Equatable, Sendable { case open(String), back, markdown(MarkdownAction) }
public struct ClaudeSharedLinksState: Equatable, Sendable {
    public var groups: [ClaudeSharedLinkGroup]
    public private(set) var selectedID: String?
    public var selected: ClaudeSharedSnapshot? { groups.lazy.flatMap(\.snapshots).first { $0.id == selectedID } }
    public init(groups: [ClaudeSharedLinkGroup] = []) { self.groups = groups }
    public mutating func reduce(_ action: ClaudeSharedLinksAction) {
        switch action {
        case .open(let id): guard groups.contains(where: { $0.snapshots.contains { $0.id == id } }) else { return }; selectedID = id
        case .back: selectedID = nil
        case .markdown: break
        }
    }
}
