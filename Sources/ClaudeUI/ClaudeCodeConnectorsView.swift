#if canImport(UIKit)
import SwiftUI

struct ClaudeCodeConnectorsView: View {
    @Binding var state: CodeConnectorState
    let back: () -> Void
    let action: (CodeConnectorAction) -> Void
    @State private var selectedID: String?
    @State private var permissionPage = false
    @State private var toolID: String?
    private var connector: CodeConnector? { state.connectors.first { $0.id == selectedID } }
    private var title: String { guard let connector else { return "Connectors" }; return permissionPage ? toolID.flatMap { id in connector.tools.first { $0.id == id }?.name } ?? "All tools" : connector.name }
    var body: some View {
        VStack(spacing: 16) {
            SheetHeader(title: title, back: true, controlDiameter: 44, close: {
                if permissionPage { permissionPage = false } else if selectedID != nil { selectedID = nil } else { back() }
            }).overlay(alignment: .trailing) {
                if connector == nil { Button { action(.add) } label: { Image(systemName: "plus").frame(width: 44, height: 44) }.glassEffect(in: .circle).padding(.trailing, 16).accessibilityLabel("Add connector") }
            }
            ScrollView {
                VStack(spacing: 16) {
                    if let connector {
                        if permissionPage {
                            RowGroup { ForEach(CodeToolPermission.allCases, id: \.self) { value in
                                SheetRow(title: value.rawValue, detail: value.detail, checked: (toolID.flatMap { id in connector.tools.first { $0.id == id }?.permission } ?? connector.commonPermission) == value) { action(.permission(connector: connector.id, tool: toolID, value: value)); permissionPage = false }.accessibilityIdentifier("code.tool.permission.\(value.rawValue)")
                                if value != .allowed { RowDivider() }
                            } }
                        } else {
                            RowGroup { SheetRow(title: "All tools", value: connector.commonPermission?.status ?? "Custom", chevron: true) { toolID = nil; permissionPage = true }.accessibilityIdentifier("code.connector.all-tools") }
                            RowGroup { ForEach(Array(connector.tools.enumerated()), id: \.element.id) { index, tool in
                                SheetRow(title: tool.name, symbol: connector.symbol, value: tool.permission.status, chevron: true) { toolID = tool.id; permissionPage = true }.accessibilityIdentifier("code.connector.tool.\(tool.id)")
                                if index < connector.tools.count - 1 { RowDivider() }
                            } }
                        }
                    } else {
                        RowGroup {
                            VStack(alignment: .leading, spacing: 9) {
                                Toggle(isOn: Binding(get: { state.discovery }, set: { action(.discovery($0)) })) { Label("Connector discovery", systemImage: "square.grid.2x2") }.tint(.blue).accessibilityIdentifier("code.connectors.discovery")
                                Text("Claude will help you find available connectors in your directory.").font(.system(size: 13)).foregroundStyle(ClaudePalette.secondary)
                            }.padding(16)
                        }
                        RowGroup { ForEach(Array(state.connectors.enumerated()), id: \.element.id) { index, row in
                            Button { if row.connected { selectedID = row.id } else { action(.connect(row.id)) } } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: row.symbol).frame(width: 23)
                                    Text(row.name).frame(maxWidth: .infinity, alignment: .leading)
                                    if row.connected { Text("\(row.tools.count)").font(.system(size: 13)).foregroundStyle(.blue).padding(.horizontal, 5).padding(.vertical, 2).background(.blue.opacity(0.15), in: .rect(cornerRadius: 5)); Image(systemName: "chevron.right").font(.system(size: 13)).foregroundStyle(ClaudePalette.secondary) }
                                    else { Text("Connect").foregroundStyle(ClaudePalette.secondary); Image(systemName: "arrow.up.right").foregroundStyle(ClaudePalette.secondary) }
                                }.padding(.horizontal, 16).frame(minHeight: 50).contentShape(.rect)
                            }.buttonStyle(.plain).accessibilityIdentifier("code.connector.\(row.id)")
                            if index < state.connectors.count - 1 { RowDivider() }
                        } }
                    }
                }.padding(.horizontal, 16)
            }.scrollIndicators(.hidden)
        }.font(.system(size: 17)).foregroundStyle(ClaudePalette.ink).background(ClaudePalette.background)
    }
}
#endif
