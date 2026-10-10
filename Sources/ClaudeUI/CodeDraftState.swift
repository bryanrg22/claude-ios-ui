import Foundation

public enum CodeEffort: String, CaseIterable, Sendable {
    case low = "Low", medium = "Medium", high = "High", extra = "Extra", max = "Max", ultracode = "Ultracode"
}
public struct CodeRepository: Identifiable, Equatable, Sendable {
    public var id: String
    public var name: String
    public var owner: String
    public var branch: String
    public init(id: String, name: String, owner: String = "", branch: String = "main") {
        self.id = id
        self.name = name
        self.owner = owner
        self.branch = branch
    }
}
public struct CodeBranch: Identifiable, Equatable, Sendable {
    public var id: String
    public var name: String
    public var isDefault: Bool
    public init(id: String, name: String, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.isDefault = isDefault
    }
}
public enum CodePermission: String, CaseIterable, Sendable {
    case auto = "Auto", acceptEdits = "Accept edits", plan = "Plan"
}
@nonexhaustive public enum CodeContextAction: Equatable, Sendable {
    case photos, camera, files, connectors, samplePhoto(Int), selectPermission(CodePermission)
}
@nonexhaustive public enum CodeDraftAction: Equatable, Sendable {
    case connectors(CodeConnectorAction), context(CodeContextAction), selectBranch(String)
    case environment(CodeEnvironmentAction), selectEnvironment(String), selectRepository(String), changeBranch,
        searchRepositories, connectRepositories
    case edit(String), selectModel(ClaudeModel), selectEffort(CodeEffort), chooseEnvironment, chooseRepository, attach,
        dictate, submit(CodeDraftState)
}
public struct CodeDraftState: Equatable, Sendable {
    public var text = ""
    public var greetingName = ""
    public var environment = "Default"
    public var repository: CodeRepository?
    public var repositories: [CodeRepository] = []
    public var branchesByRepository: [String: [CodeBranch]] = [:]
    public var permission: CodePermission = .auto
    public var connectors = CodeConnectorState()
    public var availableBranches: [CodeBranch] { repository.flatMap { branchesByRepository[$0.id] } ?? [] }
    public var environments: [CodeEnvironment] = []
    public var selectedEnvironmentID: String?
    public var environmentForm = CodeEnvironmentFormState()
    public var model: ClaudeModel = .opus
    public var effort: CodeEffort = .high
    public init() {}
    public var canSubmit: Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    public mutating func reduce(_ action: CodeDraftAction) {
        switch action {
        case .connectors(let value): connectors.reduce(value)
        case .edit(let value): text = value
        case .context(.selectPermission(let value)): permission = value
        case .selectBranch(let id):
            guard let selected = availableBranches.first(where: { $0.id == id }), repository != nil else { return }
            repository?.branch = selected.name
        case .environment(let action): environmentForm.reduce(action)
        case .selectEnvironment(let id):
            guard let selected = environments.first(where: { $0.id == id }) else { return }
            selectedEnvironmentID = id
            environment = selected.name
        case .selectRepository(let id):
            guard let selected = repositories.first(where: { $0.id == id }) else { return }
            repository = selected
        case .selectModel(let value): model = value
        case .selectEffort(let value): effort = value
        default: break
        }
    }
}
