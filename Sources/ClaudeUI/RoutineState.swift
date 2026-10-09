import Foundation

public enum RoutineFilter: String, CaseIterable, Sendable { case all = "All", active = "Active", inactive = "Inactive" }
public enum RoutineEditor: Equatable, Sendable { case description, manual }
public enum RoutineField: Equatable, Sendable { case description, name, instructions }
public enum RoutineOption: String, CaseIterable, Sendable {
    case environment = "Environment", repository = "Repository", model = "Model", connectors = "Connectors",
        notifications = "Notifications", schedule = "Schedule", githubEvent = "GitHub event"
}
public enum RoutineRepeat: String, CaseIterable, Sendable {
    case once = "Once", hourly = "Hourly", daily = "Daily", weekdays = "Weekdays", weekly = "Weekly", monthly =
        "Monthly"
}
public struct RoutineSchedule: Equatable, Sendable {
    public var repeats: RoutineRepeat = .daily
    public private(set) var hour = 1
    public private(set) var minute = 0
    public init() {}
    public mutating func setTime(hour: Int, minute: Int) {
        guard (0...23).contains(hour), (0...59).contains(minute) else { return }
        self.hour = hour
        self.minute = minute
    }
}
public struct RoutineDraft: Equatable, Sendable {
    public var name = ""
    public var instructions = ""
    public var environment = "Default"
    public var repository = "Add repository"
    public var model = "Opus 5.5"
    public var connectors = "Account default"
    public var notifications = "Push"
    public var schedule: RoutineSchedule?
    public init() {}
}
public enum RoutineAction: Equatable, Sendable {
    case newRoutine, cancel, manualSetup, backToDescription, edit(RoutineField, String)
    case draftRoutine(String), openOption(RoutineOption), selectFilter(RoutineFilter), create(RoutineDraft)
    case addSchedule, removeSchedule, toggleSchedule, setRepeat(RoutineRepeat), setTime(hour: Int, minute: Int)
}
public struct RoutineState: Equatable, Sendable {
    public private(set) var filter: RoutineFilter = .all
    public private(set) var editor: RoutineEditor?
    public var description = ""
    public var draft = RoutineDraft()
    public private(set) var scheduleExpanded = true
    public var canCreate: Bool {
        !draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !draft.instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && draft.schedule != nil
    }
    public init() {}
    public mutating func reduce(_ action: RoutineAction) {
        switch action {
        case .newRoutine:
            description = ""
            draft = RoutineDraft()
            scheduleExpanded = true
            editor = .description
        case .cancel:
            description = ""
            draft = RoutineDraft()
            scheduleExpanded = true
            editor = nil
        case .manualSetup:
            guard editor != nil else { return }
            editor = .manual
        case .backToDescription:
            guard editor != nil else { return }
            editor = .description
        case .edit(let field, let value):
            guard editor != nil else { return }
            switch field {
            case .description: description = value
            case .name: draft.name = value
            case .instructions: draft.instructions = value
            }
        case .addSchedule:
            guard editor == .manual else { return }
            if draft.schedule == nil { draft.schedule = RoutineSchedule() }
            scheduleExpanded = true
        case .removeSchedule:
            guard editor == .manual else { return }
            draft.schedule = nil
        case .toggleSchedule:
            guard editor == .manual, draft.schedule != nil else { return }
            scheduleExpanded.toggle()
        case .setRepeat(let value):
            guard editor == .manual else { return }
            draft.schedule?.repeats = value
        case .setTime(let hour, let minute):
            guard editor == .manual else { return }
            draft.schedule?.setTime(hour: hour, minute: minute)
        case .selectFilter(let value): filter = value
        case .draftRoutine, .openOption, .create: break
        }
    }
}
