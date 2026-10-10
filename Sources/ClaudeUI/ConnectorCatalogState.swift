import Foundation

public enum ClaudeConnectorCatalogSort: String, CaseIterable, Sendable {
    case `default` = "Default", popular = "Popular", trending = "Trending", new = "New", alphabetical = "Alphabetical"
}
public struct ClaudeConnectorCatalogItem: Identifiable, Equatable, Sendable {
    public var id: String
    public var name: String
    public var symbol: String
    public var subtitle: String
    public var detail: String
    public var categories: [String]
    public var connected: Bool
    public var interactive: Bool
    /// Host-supplied ordering per sort; absent ranks retain the input order.
    public var ranks: [ClaudeConnectorCatalogSort: Int]
    public init(
        id: String, name: String, symbol: String = "square.grid.2x2", subtitle: String = "", detail: String = "",
        categories: [String] = [], connected: Bool = false, interactive: Bool = false,
        ranks: [ClaudeConnectorCatalogSort: Int] = [:]
    ) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.subtitle = subtitle
        self.detail = detail
        self.categories = categories
        self.connected = connected
        self.interactive = interactive
        self.ranks = ranks
    }
}
public struct ClaudeCustomConnectorDraft: Equatable, Sendable {
    public var name = ""
    public var serverURL = ""
    public init() {}
    /// Presentation validation only. The host must validate the service independently.
    public var validatedURL: URL? {
        let value = serverURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.contains(where: { $0.isWhitespace }), let parts = URLComponents(string: value),
            parts.scheme?.lowercased() == "https", let host = parts.host, !host.isEmpty, parts.user == nil,
            parts.password == nil, parts.fragment == nil
        else { return nil }
        return parts.url
    }
    public var canSubmit: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && validatedURL != nil }
}
public enum ClaudeConnectorPresentation: String, Identifiable, Sendable {
    case catalog, custom
    public var id: String { rawValue }
}
@nonexhaustive public enum ClaudeConnectorCatalogAction: Equatable, Sendable {
    case search(String), sort(ClaudeConnectorCatalogSort), category(String?)
    case requestConnect(String), editName(String), editURL(String)
    case requestCustom(name: String, url: URL), dismiss
}
public struct ClaudeConnectorCatalogState: Equatable, Sendable {
    public var items: [ClaudeConnectorCatalogItem]
    public var categories: [String]
    public var organizationLabel: String
    public private(set) var query = ""
    public private(set) var sort: ClaudeConnectorCatalogSort = .default
    public private(set) var category: String?
    public private(set) var draft = ClaudeCustomConnectorDraft()
    public init(
        items: [ClaudeConnectorCatalogItem] = [], categories: [String] = [],
        organizationLabel: String = "your organization"
    ) {
        self.items = items
        self.categories = categories
        self.organizationLabel = organizationLabel
    }
    public var isFiltered: Bool { sort != .default || category != nil }
    public var visibleItems: [ClaudeConnectorCatalogItem] {
        let search = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return items.enumerated().filter { _, item in
            (category == nil || item.categories.contains(category!))
                && (search.isEmpty || item.name.localizedCaseInsensitiveContains(search)
                    || item.detail.localizedCaseInsensitiveContains(search))
        }.sorted { lhs, rhs in
            if sort == .alphabetical {
                let result = lhs.element.name.localizedCaseInsensitiveCompare(rhs.element.name)
                if result != .orderedSame { return result == .orderedAscending }
            }
            let left = lhs.element.ranks[sort] ?? Int.max, right = rhs.element.ranks[sort] ?? Int.max
            return left == right ? lhs.offset < rhs.offset : left < right
        }.map(\.element)
    }
    public mutating func reduce(_ action: ClaudeConnectorCatalogAction) {
        switch action {
        case .search(let query): self.query = query
        case .sort(let sort): self.sort = sort
        case .category(let category):
            guard category == nil || categories.contains(category!) else { return }
            self.category = category
        case .editName(let name): draft.name = name
        case .editURL(let url): draft.serverURL = url
        case .dismiss:
            draft = .init()
            query = ""
            sort = .default
            category = nil
        case .requestConnect, .requestCustom: break
        }
    }
}
