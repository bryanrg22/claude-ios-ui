import Foundation

public enum ClaudeBreakUnit: String, Codable, Sendable { case hours, minutes }
public enum ClaudeWeekday: String, CaseIterable, Codable, Sendable {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
    public var initial: String { String(rawValue.prefix(1)).uppercased() }
}
public enum ClaudeTimeFocusAction: Equatable, Sendable {
    case selectHours(Int?), selectMinutes(Int?), quietDayTapped(ClaudeWeekday)
}
/// Values displayed by the captured embedded form, without scheduling or account persistence.
public struct ClaudeTimeFocusState: Equatable, Codable, Sendable {
    public private(set) var hours: Int?
    public private(set) var minutes: Int?
    public init(hours: Int? = nil, minutes: Int? = nil) {
        self.hours = hours.flatMap { (1...12).contains($0) ? $0 : nil }
        self.minutes = minutes.flatMap { [15, 30, 45].contains($0) ? $0 : nil }
    }
    private enum CodingKeys: String, CodingKey { case hours, minutes }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(hours: try values.decodeIfPresent(Int.self, forKey: .hours), minutes: try values.decodeIfPresent(Int.self, forKey: .minutes))
    }
    public mutating func reduce(_ action: ClaudeTimeFocusAction) {
        switch action {
        case .selectHours(let value): if let value, !(1...12).contains(value) { return }; hours = value
        case .selectMinutes(let value): if let value, ![15, 30, 45].contains(value) { return }; minutes = value
        case .quietDayTapped: break // The selected-day expansion has not been captured; host owns this route.
        }
    }
}
