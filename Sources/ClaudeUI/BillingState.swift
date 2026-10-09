import Foundation

public enum ClaudeSubscriptionOrigin: Equatable, Sendable { case unknown, website, appStore, other(String) }
public enum ClaudeBillingAction: Equatable, Sendable {
    case requestManage, dismissNotice, requestWebsiteManagement(URL?), requestRestore
}
/// Subscription truth belongs to the host. Only the observed website notice is local presentation state.
public struct ClaudeBillingState: Equatable, Sendable {
    public var planLabel: String
    public var origin: ClaudeSubscriptionOrigin
    public var managementURL: URL?
    public private(set) var showsWebsiteNotice = false
    public init(planLabel: String = "—", origin: ClaudeSubscriptionOrigin = .unknown, managementURL: URL? = nil) {
        self.planLabel = planLabel
        self.origin = origin
        self.managementURL = managementURL
    }
    public mutating func reduce(_ action: ClaudeBillingAction) {
        switch action {
        case .requestManage: showsWebsiteNotice = origin == .website
        case .dismissNotice, .requestWebsiteManagement: showsWebsiteNotice = false
        case .requestRestore: break
        }
    }
}
