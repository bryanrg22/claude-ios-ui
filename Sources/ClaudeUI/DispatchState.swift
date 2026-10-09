import Foundation

public enum DispatchConnection: Equatable, Sendable { case unknown, online, offline }
public struct DispatchMessage: Identifiable, Equatable, Sendable {
    public var id: UUID
    public var text: String
    public var timestamp: String
    public var isUser: Bool
    public init(id: UUID = UUID(), text: String, timestamp: String = "", isUser: Bool = false) { self.id = id; self.text = text; self.timestamp = timestamp; self.isUser = isUser }
}
public enum DispatchAction: Equatable, Sendable { case reload, close, attach, submit(String) }
/// Host-provided presentation only. Online is never inferred from messages or a timer.
public struct DispatchState: Equatable, Sendable {
    public var connection: DispatchConnection = .unknown
    public var draft = ""
    public private(set) var messages: [DispatchMessage] = []
    public private(set) var loading = false
    public private(set) var loadID: UUID?
    public var error: String?
    public init() {}
    public mutating func reduce(_ action: DispatchAction) {
        switch action {
        case .reload: loading = true; loadID = UUID(); error = nil
        case .close: loading = false; loadID = nil
        case .attach, .submit: break
        }
    }
    public mutating func finishLoading(_ messages: [DispatchMessage], requestID: UUID) {
        guard loading, loadID == requestID else { return }
        self.messages = messages; loading = false; loadID = nil
    }
    public mutating func failLoading(_ error: String, requestID: UUID) {
        guard loading, loadID == requestID else { return }
        self.error = error; loading = false; loadID = nil
    }
}
