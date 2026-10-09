import Foundation

public enum ClaudeCapability: String, CaseIterable, Sendable {
    case artifacts, inlineVisualizations, codeExecution, switchFlaggedModel, searchChats, generateMemory,
        sensitiveMemory
    public var title: String {
        switch self {
        case .artifacts: "Artifacts"
        case .inlineVisualizations: "Inline visualizations"
        case .codeExecution: "Code execution and file creation"
        case .switchFlaggedModel: "Switch models when a message is flagged"
        case .searchChats: "Search and reference chats"
        case .generateMemory: "Generate memory from chats"
        case .sensitiveMemory: "Include sensitive topics in memory"
        }
    }
    public var subtitle: String {
        switch self {
        case .artifacts: ""
        case .inlineVisualizations:
            "Allow Claude to generate interactive visualizations, charts, and diagrams directly in the conversation."
        case .codeExecution:
            "Allow Claude to execute code and create and edit docs, spreadsheets, presentations, PDFs, and data reports."
        case .switchFlaggedModel:
            "When safety measures flag a message, automatically switch to a different model to keep chatting. When off, your chat will pause instead."
        case .searchChats: "Allow Claude to search for relevant details in past chats."
        case .generateMemory: "Allow Claude to generate memory from your chats."
        case .sensitiveMemory:
            "Allow Claude to save details about sensitive topics like health conditions or religious beliefs to memory."
        }
    }
    public var symbol: String? {
        switch self {
        case .artifacts: "square.on.circle"
        case .inlineVisualizations: "chart.xyaxis.line"
        case .codeExecution: "doc.text"
        case .switchFlaggedModel: "arrow.up.arrow.down"
        default: nil
        }
    }
    public var hasHelp: Bool { [.searchChats, .generateMemory, .sensitiveMemory].contains(self) }
}
public struct ClaudeCapabilityValue: Equatable, Sendable {
    public var isEnabled: Bool
    public var isEditable: Bool
    public var dependencyLabel: String?
    public init(isEnabled: Bool = false, isEditable: Bool = true, dependencyLabel: String? = nil) {
        self.isEnabled = isEnabled
        self.isEditable = isEditable
        self.dependencyLabel = dependencyLabel
    }
}
public enum ClaudeCapabilityAction: Equatable, Sendable {
    case requestEnabled(ClaudeCapability, Bool), openHelp(ClaudeCapability, URL?), openMemoryFiles
}
/// No capability or memory-consent value is mutated automatically by a request.
public struct ClaudeCapabilitiesState: Equatable, Sendable {
    public var values: [ClaudeCapability: ClaudeCapabilityValue]
    public var helpURLs: [ClaudeCapability: URL]
    public init(values: [ClaudeCapability: ClaudeCapabilityValue] = [:], helpURLs: [ClaudeCapability: URL] = [:]) {
        self.values = values
        self.helpURLs = helpURLs
    }
    public subscript(_ capability: ClaudeCapability) -> ClaudeCapabilityValue { values[capability] ?? .init() }
}
