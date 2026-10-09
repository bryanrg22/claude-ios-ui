import Foundation

public enum ClaudeNotificationPreference: String, CaseIterable, Codable, Sendable {
    case replies, scheduledTasks, researchComplete, codeUpdates, codePermissions, dispatchMessages, productUpdates
    public var title: String {
        switch self {
        case .replies: "Replies"
        case .scheduledTasks: "Scheduled tasks"
        case .researchComplete: "Research complete"
        case .codeUpdates: "Code and project updates"
        case .codePermissions: "Code permission requests"
        case .dispatchMessages: "Dispatch messages"
        case .productUpdates: "Product updates"
        }
    }
    public var subtitle: String {
        switch self {
        case .replies: "Get notified when Claude finishes a reply."
        case .scheduledTasks: "Get notified when scheduled tasks finish, can’t run, or need your input"
        case .researchComplete: "Get notified when research completes"
        case .codeUpdates: "Get notified when Code sessions or projects have updates"
        case .codePermissions: "Get notified when Code sessions need your approval to use a tool"
        case .dispatchMessages: "Get notified when Claude messages you in Dispatch."
        case .productUpdates: "Get notified about new features, tips, and occasional promotions"
        }
    }
    public static let groups: [[Self]] = [[.replies, .scheduledTasks, .researchComplete], [.codeUpdates, .codePermissions, .dispatchMessages], [.productUpdates]]
}
/// Host-persistable presentation preferences. Does not read or write system notification settings.
public struct ClaudeNotificationPreferences: Equatable, Codable, Sendable {
    public var enabled: Set<ClaudeNotificationPreference>
    public init(enabled: Set<ClaudeNotificationPreference> = []) { self.enabled = enabled }
    public subscript(_ preference: ClaudeNotificationPreference) -> Bool {
        get { enabled.contains(preference) }
        set { if newValue { enabled.insert(preference) } else { enabled.remove(preference) } }
    }
}
