import Foundation

public enum CodeFilter: String, CaseIterable, Sendable {
    case all = "All", needsInput = "Needs input", readyForReview = "Ready for review", working = "Working", completed =
        "Completed", archived = "Archived"
}
public enum CodeSessionStatus: Equatable, Sendable { case idle, needsInput, readyForReview, working, completed }
public enum CodeSessionLocation: Equatable, Sendable { case none, connectedComputer, unavailableComputer, cloud }
public struct CodeSession: Identifiable, Equatable, Sendable {
    public var id: String
    public var title: String
    public var detail: String
    public var status: CodeSessionStatus
    public var location: CodeSessionLocation
    public var archived: Bool
    public init(
        id: String, title: String, detail: String = "", status: CodeSessionStatus = .idle,
        location: CodeSessionLocation = .none, archived: Bool = false
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.status = status
        self.location = location
        self.archived = archived
    }
}
public struct CodeDevice: Identifiable, Equatable, Sendable {
    public var id: String
    public var name: String
    public var detail: String
    public init(id: String, name: String, detail: String = "") {
        self.id = id
        self.name = name
        self.detail = detail
    }
}
@nonexhaustive public enum CodeAction: Equatable, Sendable {
    case selectFilter(CodeFilter), openSession(String), openDevice(String), addDevice, copyRemoteCommand, newSession,
        closeNewSession, editor(CodeDraftAction), search, openRoutines, closeRoutines, routines(RoutineAction)
}
/// Pure presentation data. Session/device actions are integration hooks and never start work.
public struct CodeState: Equatable, Sendable {
    public var sessions: [CodeSession] = []
    public var devices: [CodeDevice] = []
    public private(set) var showingRoutines = false
    public var routines = RoutineState()
    public var draft = CodeDraftState()
    public private(set) var showingNewSession = false
    public private(set) var filter: CodeFilter = .all
    public init() {}
    public var visibleSessions: [CodeSession] {
        sessions.filter { session in
            if filter == .archived { return session.archived }
            guard !session.archived else { return false }
            switch filter {
            case .all: return true
            case .needsInput: return session.status == .needsInput
            case .readyForReview: return session.status == .readyForReview
            case .working: return session.status == .working
            case .completed: return session.status == .completed
            case .archived: return false
            }
        }
    }
    public mutating func reduce(_ action: CodeAction) {
        switch action {
        case .selectFilter(let value): filter = value
        case .newSession: showingNewSession = true
        case .closeNewSession:
            showingNewSession = false
            draft.environmentForm.reduce(.cancel)
        case .editor(let action): draft.reduce(action)
        case .openRoutines: showingRoutines = true
        case .closeRoutines:
            showingRoutines = false
            routines.reduce(.cancel)
        case .routines(let action): routines.reduce(action)
        default: break
        }
    }
}
