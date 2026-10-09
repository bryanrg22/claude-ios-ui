import Foundation

public enum CodeToolPermission: String, CaseIterable, Sendable {
    case blocked = "Blocked", approval = "Needs approval", allowed = "Always allow"
    public var status: String {
        switch self {
        case .blocked: "Never"
        case .approval: "Ask"
        case .allowed: "Always allow"
        }
    }
    public var detail: String {
        switch self {
        case .blocked: "This tool is hidden from Claude"
        case .approval: "Claude asks before each use, except in sessions set to Automatically approve"
        case .allowed: "Claude can use this tool without asking"
        }
    }
}
public struct CodeConnectorTool: Identifiable, Equatable, Sendable {
    public var id: String
    public var name: String
    public var permission: CodeToolPermission
    public init(id: String, name: String, permission: CodeToolPermission = .approval) {
        self.id = id
        self.name = name
        self.permission = permission
    }
}
/// Injected presentation data. `connected` does not establish or verify a service connection.
public struct CodeConnector: Identifiable, Equatable, Sendable {
    public var id: String
    public var name: String
    public var symbol: String
    public var connected: Bool
    public var tools: [CodeConnectorTool]
    public init(
        id: String, name: String, symbol: String = "square.grid.2x2", connected: Bool = false,
        tools: [CodeConnectorTool] = []
    ) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.connected = connected
        self.tools = tools
    }
    public var commonPermission: CodeToolPermission? {
        guard let first = tools.first?.permission, tools.allSatisfy({ $0.permission == first }) else { return nil }
        return first
    }
}
public enum CodeConnectorAction: Equatable, Sendable {
    case discovery(Bool), add, connect(String), permission(connector: String, tool: String?, value: CodeToolPermission)
}
public struct CodeConnectorState: Equatable, Sendable {
    public var discovery = false
    public var connectors: [CodeConnector] = []
    public init() {}
    public mutating func reduce(_ action: CodeConnectorAction) {
        switch action {
        case .discovery(let value): discovery = value
        case let .permission(id, toolID, value):
            guard let index = connectors.firstIndex(where: { $0.id == id && $0.connected }) else { return }
            for toolIndex in connectors[index].tools.indices
            where toolID == nil || connectors[index].tools[toolIndex].id == toolID {
                connectors[index].tools[toolIndex].permission = value
            }
        default: break
        }
    }
}
