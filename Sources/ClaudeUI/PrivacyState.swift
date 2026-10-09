import Foundation

public enum ClaudePrivacyLink: String, CaseIterable, Codable, Sendable {
    case privacyCenter, privacyPolicy, learnMore
    public var title: String {
        switch self {
        case .privacyCenter: "Privacy Center"
        case .privacyPolicy: "Privacy Policy"
        case .learnMore: "Learn More"
        }
    }
}
public enum ClaudePrivacyAction: Equatable, Sendable {
    case requestModelImprovement(Bool)
    case openLink(ClaudePrivacyLink, URL?)
}
/// The host owns consent truth and destination URLs. UI requests never change consent by themselves.
public struct ClaudePrivacyState: Equatable, Sendable {
    public var allowsModelImprovement: Bool
    public var links: [ClaudePrivacyLink: URL]
    public init(allowsModelImprovement: Bool = false, links: [ClaudePrivacyLink: URL] = [:]) {
        self.allowsModelImprovement = allowsModelImprovement
        self.links = links
    }
}
