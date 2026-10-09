#if canImport(UIKit)
import SwiftUI

/// Offline catalog presentation. Logos, rows and connection truth are supplied by the host.
public struct ClaudeConnectorCatalogView: View {
    public let state: ClaudeConnectorCatalogState
    public let presentation: ClaudeConnectorPresentation
    private let iconContent: ((ClaudeConnectorCatalogItem) -> AnyView)?
    private let action: (ClaudeConnectorCatalogAction) -> Void
    @Environment(\.colorScheme) private var colorScheme
    public init(state: ClaudeConnectorCatalogState, presentation: ClaudeConnectorPresentation, iconContent: ((ClaudeConnectorCatalogItem) -> AnyView)? = nil, action: @escaping (ClaudeConnectorCatalogAction) -> Void) { self.state = state; self.presentation = presentation; self.iconContent = iconContent; self.action = action }
    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(presentation == .catalog ? "Connectors" : "Add custom connector").font(.system(size: 17, weight: .semibold)).padding(.horizontal, 50)
                HStack {
                    Button { action(.dismiss) } label: { Image(systemName: "xmark").font(.system(size: 21, weight: .light)).frame(width: 44, height: 44) }.glassEffect(in: .circle).accessibilityIdentifier("settings.catalog.close").accessibilityLabel("Close")
                    Spacer()
                    if presentation == .catalog { sortMenu }
                }
            }.frame(height: 44).padding(16)
            if presentation == .custom { customForm } else { catalog }
        }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink).tint(ClaudePalette.ink).environment(\.symbolVariants, .none)
    }
    private var sortMenu: some View {
        Menu {
            Picker("Sort", selection: Binding(get: { state.sort }, set: { action(.sort($0)) })) { ForEach(ClaudeConnectorCatalogSort.allCases, id: \.self) { Text($0.rawValue).tag($0) } }.pickerStyle(.inline)
            Picker("Category", selection: Binding<String?>(get: { state.category }, set: { action(.category($0)) })) {
                Text("All").tag(String?.none)
                ForEach(state.categories, id: \.self) { Text($0).tag(Optional($0)) }
            }.pickerStyle(.inline)
        } label: {
            Image(systemName: "arrow.up.arrow.down").font(.system(size: 21, weight: .light)).frame(width: 36, height: 36).background(state.isFiltered ? ClaudePalette.orange : Color.clear, in: .circle).frame(width: 44, height: 44)
        }.glassEffect(in: .circle).accessibilityLabel("Sort and filter connectors").accessibilityIdentifier("settings.catalog.sort")
    }
    private var catalog: some View {
        ScrollView {
            LazyVStack(spacing: 8) { ForEach(state.visibleItems) { item in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Group { if let iconContent { iconContent(item) } else { AnyView(Image(systemName: item.symbol).font(.system(size: 23))) } }.frame(width: 32, height: 32).overlay(RoundedRectangle(cornerRadius: 8).stroke(ClaudePalette.secondary.opacity(0.25)))
                        VStack(alignment: .leading, spacing: 2) {
                            (Text(item.name).fontWeight(.semibold) + Text(item.interactive ? " Interactive" : "").foregroundColor(Color.secondary).font(.system(size: 11))).font(.system(size: 15))
                            if !item.subtitle.isEmpty { Text(item.subtitle).font(.system(size: 11)).foregroundStyle(ClaudePalette.secondary) }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        if item.connected { Text("Connected").font(.system(size: 13)).foregroundStyle(.green) }
                        else { Button { action(.requestConnect(item.id)) } label: { Text("Connect").font(.system(size: 16, weight: .semibold)).padding(.horizontal, 16).padding(.vertical, 6).foregroundStyle(ClaudePalette.background).background(ClaudePalette.ink, in: .capsule) }.buttonStyle(.plain).accessibilityIdentifier("settings.catalog.connect." + item.id) }
                    }
                    Text(item.detail).font(.system(size: 13.3)).foregroundStyle(ClaudePalette.secondary).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                }.padding(16).frame(maxWidth: .infinity, alignment: .leading).background(ClaudePalette.panel, in: RoundedRectangle(cornerRadius: 20))
            } }.padding(.horizontal, 16).padding(.bottom, 12)
        }.accessibilityIdentifier("settings.catalog.scroll")
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").font(.system(size: 20))
                ClaudeProfileTextField(text: state.query, placeholder: "Search", identifier: "settings.catalog.search") { action(.search($0)) }.frame(height: 24)
            }.padding(.horizontal, 16).frame(height: 48).glassEffect(in: .capsule).padding(.horizontal, 28).padding(.bottom, 10)
        }
    }
    private var customForm: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Adding to " + state.organizationLabel).font(.system(size: 15)).lineSpacing(3)
                VStack(alignment: .leading, spacing: 8) {
                    input(text: state.draft.name, placeholder: "Name", id: "name") { action(.editName($0)) }
                    Text("Shown in the connectors list.").font(.system(size: 13.3))
                }
                VStack(alignment: .leading, spacing: 8) {
                    input(text: state.draft.serverURL, placeholder: "MCP server URL", id: "url") { action(.editURL($0)) }
                    Text("The HTTPS address where the server accepts MCP requests, for example https://mcp.example.com/mcp.").font(.system(size: 13.3)).lineSpacing(2)
                }
                Text("Only use connectors from developers you trust. Anthropic does not control which tools developers make available and cannot verify that they will work as intended or that they won’t change.").font(.system(size: 15)).lineSpacing(3).padding(.top, 10)
                Button {
                    if state.draft.canSubmit, let url = state.draft.validatedURL { action(.requestCustom(name: state.draft.name.trimmingCharacters(in: .whitespacesAndNewlines), url: url)) }
                } label: { Text("Continue").font(.system(size: 16, weight: .medium)).frame(maxWidth: .infinity).frame(height: 40).foregroundStyle(ClaudePalette.background).background(ClaudePalette.ink.opacity(state.draft.canSubmit ? 1 : 0.45), in: RoundedRectangle(cornerRadius: 10)) }.buttonStyle(.plain).disabled(!state.draft.canSubmit).accessibilityIdentifier("settings.custom.continue")
            }.foregroundStyle(ClaudePalette.secondary).padding(16)
        }.background(colorScheme == .dark ? Color(white: 0.035) : Color(white: 0.98)).accessibilityIdentifier("settings.custom.scroll").scrollDismissesKeyboard(.interactively)
    }
    private func input(text: String, placeholder: String, id: String, update: @escaping (String) -> Void) -> some View {
        ClaudeProfileTextField(text: text, placeholder: placeholder, identifier: "settings.custom." + id, update: update, isURL: id == "url").frame(height: 40).padding(.horizontal, 16).background(ClaudePalette.background, in: RoundedRectangle(cornerRadius: 10)).overlay(RoundedRectangle(cornerRadius: 10).stroke(ClaudePalette.secondary.opacity(0.2)))
    }
}
#endif
