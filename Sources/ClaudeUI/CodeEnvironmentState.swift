import Foundation

public struct CodeEnvironment: Identifiable, Equatable, Sendable {
    public var id: String
    public var name: String
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
public enum CodeNetworkAccess: String, CaseIterable, Sendable {
    case none = "No network access", trusted = "Trusted network access", full = "Full network access", custom = "Custom"
    public var detail: String {
        switch self {
        case .none: "Blocks internet access for maximum security."
        case .trusted: "Downloads packages from verified sources."
        case .full: "Unrestricted internet access for maximum flexibility."
        case .custom: "Create a list of allowed domains."
        }
    }
}
public struct CodeEnvironmentDraft: Equatable, Sendable {
    public var name = ""
    public var variables = ""
    public var network: CodeNetworkAccess = .trusted
    public init() {}
}
public enum CodeEnvironmentAction: Equatable, Sendable {
    case begin, cancel, editName(String), editVariables(String), selectNetwork(CodeNetworkAccess), create(
        CodeEnvironmentDraft), formatHelp, help
}
public struct CodeEnvironmentFormState: Equatable, Sendable {
    public private(set) var presented = false
    public var draft = CodeEnvironmentDraft()
    public init() {}
    public mutating func reduce(_ action: CodeEnvironmentAction) {
        switch action {
        case .begin:
            draft = CodeEnvironmentDraft()
            presented = true
        case .cancel:
            draft = CodeEnvironmentDraft()
            presented = false
        case .editName(let value):
            guard presented else { return }
            draft.name = value
        case .editVariables(let value):
            guard presented else { return }
            draft.variables = value
        case .selectNetwork(let value):
            guard presented else { return }
            draft.network = value
        case .create, .formatHelp, .help: break
        }
    }
}
