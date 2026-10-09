import Foundation

public enum ClaudeSettingsConnectorAction: Equatable, Sendable {
    case openConnector(String), openTool(String), openAllTools, openCatalog, openCustom, back
    case catalog(ClaudeConnectorCatalogAction)
    case requestAllPermissions(connector: String, permission: CodeToolPermission)
    case requestDiscovery(Bool), requestConnect(String), requestCatalog, requestAllTools(String)
    case requestPermission(connector: String, tool: String, permission: CodeToolPermission)
}
/// Reuses Code's injectable connector/tool records and permission labels while keeping
/// Settings account permissions host-owned. Navigation, catalog filters, and custom drafts are local; account truth is host-owned.
public struct ClaudeSettingsConnectorState: Equatable, Sendable {
    public var discovery: Bool
    public var connectors: [CodeConnector]
    public var toolDescriptions: [String: [String: String]]
    public private(set) var connectorID: String?
    public private(set) var toolID: String?
    private var allTools = false
    public var showingAllTools: Bool { allTools && connector != nil }
    public private(set) var presentation: ClaudeConnectorPresentation?
    public var catalog = ClaudeConnectorCatalogState()
    public var connector: CodeConnector? { connectors.first { $0.id == connectorID && $0.connected } }
    public var tool: CodeConnectorTool? { connector?.tools.first { $0.id == toolID } }
    public var toolDescription: String { guard let connector, let tool else { return "" }; return toolDescriptions[connector.id]?[tool.id] ?? "" }
    public init(discovery: Bool = false, connectors: [CodeConnector] = [], toolDescriptions: [String: [String: String]] = [:]) { self.discovery = discovery; self.connectors = connectors; self.toolDescriptions = toolDescriptions }
    public mutating func reduce(_ action: ClaudeSettingsConnectorAction) {
        switch action {
        case .openConnector(let id): guard connectors.contains(where: { $0.id == id && $0.connected }) else { return }; connectorID = id; toolID = nil; allTools = false
        case .openAllTools: guard connector != nil else { return }; allTools = true; toolID = nil
        case .openCatalog: presentation = .catalog
        case .openCustom: presentation = .custom
        case .catalog(let action): guard presentation != nil else { return }; catalog.reduce(action); if case .dismiss = action { presentation = nil }
        case .openTool(let id): guard connector?.tools.contains(where: { $0.id == id }) == true else { return }; toolID = id; allTools = false
        case .back: if showingAllTools { allTools = false } else if toolID != nil { toolID = nil } else { connectorID = nil }
        default: break
        }
    }
    public mutating func close() { connectorID = nil; toolID = nil; allTools = false; presentation = nil; catalog.reduce(.dismiss) }
}
