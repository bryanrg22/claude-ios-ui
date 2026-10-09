import Foundation

public enum ClaudeWidgetDestination: String, CaseIterable, Sendable, Codable {
    case chat, camera, voice, code, dispatch, newCodeSession, searchCode
    public var url: URL { URL(string: "claude-ui-demo://widget/" + rawValue)! }
    public init?(url: URL) {
        guard url.scheme == "claude-ui-demo", url.host == "widget", url.user == nil, url.password == nil, url.port == nil, url.query == nil, url.fragment == nil,
              let value = Self(rawValue: String(url.path.dropFirst())), url.path == "/" + value.rawValue, url.absoluteString == value.url.absoluteString else { return nil }
        self = value
    }
    public var title: String { switch self { case .chat: "Chat"; case .camera: "Camera"; case .voice: "Voice"; case .code: "Code"; case .dispatch: "Dispatch"; case .newCodeSession: "New Code session"; case .searchCode: "Search Code" } }
}
public enum ClaudeWidgetLayout: String, CaseIterable, Sendable, Codable { case quickActionsSmall, quickActionsMedium, codeSmall }
public struct ClaudeWidgetPresentation: Equatable, Sendable, Codable {
    public var layout: ClaudeWidgetLayout
    public init(layout: ClaudeWidgetLayout) { self.layout = layout }
    public var primary: ClaudeWidgetDestination { layout == .codeSmall ? .code : .chat }
    public var shortcuts: [ClaudeWidgetDestination] { switch layout { case .quickActionsSmall: [.camera, .voice]; case .quickActionsMedium: [.camera, .voice, .code, .dispatch]; case .codeSmall: [.newCodeSession, .searchCode] } }
}
