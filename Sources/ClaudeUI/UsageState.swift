import Foundation

private func normalizedUsage(_ value: Double?) -> Double? {
    guard let value, value.isFinite else { return nil }
    return min(100, max(0, value))
}
public struct ClaudeUsageMeter: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let usedPercentage: Double?
    public let resetLabel: String
    public init(id: String, title: String, usedPercentage: Double? = nil, resetLabel: String = "") {
        self.id = id
        self.title = title
        self.usedPercentage = normalizedUsage(usedPercentage)
        self.resetLabel = resetLabel
    }
    public var fractionUsed: Double? { usedPercentage.map { $0 / 100 } }
    public var usageLabel: String { usedPercentage.map { "\(Int($0.rounded()))% used" } ?? "—" }
}
public struct ClaudeUsageCredit: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let badge: String
    public let usedPercentage: Double?
    public init(id: String, title: String, subtitle: String = "", badge: String = "", usedPercentage: Double? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.usedPercentage = normalizedUsage(usedPercentage)
    }
    public var fractionUsed: Double? { usedPercentage.map { $0 / 100 } }
}
public enum ClaudeUsageLink: String, Sendable { case usageHelp, creditsHelp }
public enum ClaudeUsageAction: Equatable, Sendable {
    case refresh, requestCreditsEnabled(Bool), requestPurchase
    case openLink(ClaudeUsageLink, URL?)
}
/// All meters, amounts, transaction labels, URLs and consent truth are supplied by the host.
/// Actions request host behavior; the package never charges credits, purchases, or fetches usage.
public struct ClaudeUsageState: Equatable, Sendable {
    public var currentSession: ClaudeUsageMeter?
    public var weekly: [ClaudeUsageMeter]
    public var creditsEnabled: Bool
    public var balanceLabel: String
    public var credits: [ClaudeUsageCredit]
    public var usageHelpURL: URL?
    public var creditsHelpURL: URL?
    public init(
        currentSession: ClaudeUsageMeter? = nil, weekly: [ClaudeUsageMeter] = [], creditsEnabled: Bool = false,
        balanceLabel: String = "—", credits: [ClaudeUsageCredit] = [], usageHelpURL: URL? = nil,
        creditsHelpURL: URL? = nil
    ) {
        self.currentSession = currentSession
        self.weekly = weekly
        self.creditsEnabled = creditsEnabled
        self.balanceLabel = balanceLabel
        self.credits = credits
        self.usageHelpURL = usageHelpURL
        self.creditsHelpURL = creditsHelpURL
    }
}
