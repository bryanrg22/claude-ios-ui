import Foundation

public struct ClaudeMemoryFile: Identifiable, Equatable, Sendable {
    public let id: String
    public var title: String
    public var updatedLabel: String
    public var summary: String
    public var markdown: String
    public init(id: String, title: String, updatedLabel: String = "", summary: String = "", markdown: String = "") { self.id = id; self.title = title; self.updatedLabel = updatedLabel; self.summary = summary; self.markdown = markdown }
}
public struct ClaudeMemoryFileGroup: Identifiable, Equatable, Sendable {
    public let id: String
    public var title: String
    public var files: [ClaudeMemoryFile]
    public init(id: String, title: String, files: [ClaudeMemoryFile]) { self.id = id; self.title = title; self.files = files }
}
public struct ClaudeMemoryDeletionRequest: Equatable, Sendable {
    public let id: UUID
    public let fileID: String
    public init(id: UUID = UUID(), fileID: String) { self.id = id; self.fileID = fileID }
}
public enum ClaudeMemoryFilesAction: Equatable, Sendable {
    case open(String), back, close, editDraft(String), replaceDraft(String)
    case submitInstruction(fileID: String?, text: String)
    case askDelete, cancelDelete, confirmDelete
    case markdown(MarkdownAction)
}
public struct ClaudeMemoryFilesState: Equatable, Sendable {
    public var groups: [ClaudeMemoryFileGroup]
    public private(set) var editorRevision: UInt64 = 0
    public private(set) var selectedID: String?
    public private(set) var confirmationFileID: String?
    public private(set) var pendingDeletion: ClaudeMemoryDeletionRequest?
    private var drafts: [String: String] = [:]
    private var listDraft = ""
    public var selected: ClaudeMemoryFile? { file(selectedID) }
    public var deletionCandidate: ClaudeMemoryFile? { file(confirmationFileID) }
    public var draft: String { selected.map { drafts[$0.id] ?? "" } ?? listDraft }
    public init(groups: [ClaudeMemoryFileGroup] = []) { self.groups = groups }
    private func file(_ id: String?) -> ClaudeMemoryFile? { groups.lazy.flatMap(\.files).first { $0.id == id } }
    public mutating func reduce(_ action: ClaudeMemoryFilesAction) {
        switch action {
        case .open(let id): guard file(id) != nil else { return }; selectedID = id; confirmationFileID = nil; pendingDeletion = nil
        case .back: selectedID = nil; confirmationFileID = nil; pendingDeletion = nil
        case .close: selectedID = nil; confirmationFileID = nil; pendingDeletion = nil; drafts = [:]; listDraft = ""
        case .replaceDraft(let text): reduce(.editDraft(text)); editorRevision &+= 1
        case .editDraft(let text): if let selected { drafts[selected.id] = text } else { listDraft = text }
        case .askDelete: guard let selected, pendingDeletion == nil else { return }; confirmationFileID = selected.id
        case .cancelDelete: confirmationFileID = nil
        case .confirmDelete:
            guard let candidate = deletionCandidate, selected?.id == candidate.id, pendingDeletion == nil else { return }
            pendingDeletion = .init(fileID: candidate.id); confirmationFileID = nil
        case .submitInstruction, .markdown: break
        }
    }
    /// Only a matching host acknowledgement removes the fixture. Late callbacks after navigation are ignored.
    public mutating func acknowledgeDeletion(requestID: UUID) {
        guard let request = pendingDeletion, request.id == requestID, selected?.id == request.fileID else { return }
        for index in groups.indices { groups[index].files.removeAll { $0.id == request.fileID } }
        drafts.removeValue(forKey: request.fileID); reduce(.back)
    }
    public mutating func rejectDeletion(requestID: UUID) { guard pendingDeletion?.id == requestID else { return }; pendingDeletion = nil }
}
