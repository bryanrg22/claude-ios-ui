#if canImport(UIKit)
    import SwiftUI

    /// The host may supply licensed connector artwork. The default uses each record's SF Symbol.
    public struct ClaudeSettingsConnectorsView: View {
        public let state: ClaudeSettingsConnectorState
        private let iconContent: ((CodeConnector) -> AnyView)?
        private let action: (ClaudeSettingsConnectorAction) -> Void
        public init(
            state: ClaudeSettingsConnectorState, iconContent: ((CodeConnector) -> AnyView)? = nil,
            action: @escaping (ClaudeSettingsConnectorAction) -> Void
        ) {
            self.state = state
            self.iconContent = iconContent
            self.action = action
        }
        public var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let connector = state.connector {
                        if state.showingAllTools {
                            policy(connector: connector, tool: nil)
                        } else if let tool = state.tool {
                            policy(connector: connector, tool: tool)
                        } else {
                            tools(connector)
                        }
                    } else {
                        list
                    }
                }.padding(.horizontal, 16).padding(.top, 26).padding(.bottom, 24)
            }.accessibilityIdentifier("settings.connectors.scroll")
        }
        private var list: some View {
            Group {
                RowGroup {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "square.grid.2x2").font(.system(size: 20)).foregroundStyle(
                            ClaudePalette.secondary
                        ).frame(width: 24).padding(.top, 2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Connector discovery").font(.system(size: 17))
                            Text("Claude will help you find available connectors in your directory.").font(
                                .system(size: 13.3)
                            ).foregroundStyle(ClaudePalette.secondary).lineSpacing(2).fixedSize(
                                horizontal: false, vertical: true)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        Toggle(
                            "Connector discovery",
                            isOn: Binding(get: { state.discovery }, set: { action(.requestDiscovery($0)) })
                        ).labelsHidden().tint(ClaudeSettingsColors.switchTint).frame(width: 63).accessibilityIdentifier(
                            "settings.connectors.discovery")
                    }.padding(16)
                }
                RowGroup {
                    ForEach(Array(state.connectors.enumerated()), id: \.element.id) { index, connector in
                        if index > 0 { Divider().padding(.leading, 48).padding(.trailing, 16) }
                        Button {
                            action(connector.connected ? .openConnector(connector.id) : .requestConnect(connector.id))
                        } label: {
                            HStack(spacing: 8) {
                                icon(connector)
                                Text(connector.name).font(.system(size: 17)).frame(
                                    maxWidth: .infinity, alignment: .leading)
                                if connector.connected {
                                    Text("\(connector.tools.count)").font(.system(size: 13)).foregroundStyle(
                                        ClaudeSettingsColors.switchTint
                                    ).padding(.horizontal, 8).padding(.vertical, 5).background(
                                        Color.blue.opacity(0.18), in: .capsule)
                                    chevron
                                } else {
                                    Text("Connect").font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary)
                                    Image(systemName: "arrow.up.right.square").font(.system(size: 19)).foregroundStyle(
                                        ClaudePalette.secondary)
                                }
                            }.foregroundStyle(ClaudePalette.ink).padding(.horizontal, 16).frame(minHeight: 55)
                                .contentShape(Rectangle())
                        }.buttonStyle(.plain).accessibilityIdentifier("settings.connector." + connector.id)
                    }
                }
            }
        }
        private func tools(_ connector: CodeConnector) -> some View {
            Group {
                RowGroup {
                    Button {
                        action(.openAllTools)
                    } label: {
                        HStack {
                            Text("All tools")
                            Spacer()
                            Text(connector.commonPermission?.status ?? "Custom").foregroundStyle(
                                ClaudePalette.secondary)
                            chevron
                        }.font(.system(size: 17)).padding(.horizontal, 16).frame(height: 50).contentShape(Rectangle())
                    }.buttonStyle(.plain).accessibilityIdentifier("settings.connector.allTools")
                }
                RowGroup {
                    ForEach(Array(connector.tools.enumerated()), id: \.element.id) { index, tool in
                        if index > 0 { Divider().padding(.leading, 48).padding(.trailing, 16) }
                        Button {
                            action(.openTool(tool.id))
                        } label: {
                            HStack(spacing: 8) {
                                ViewThatFits(in: .horizontal) {
                                    HStack(spacing: 8) {
                                        icon(connector)
                                        Text(tool.name).fixedSize()
                                        Spacer(minLength: 8)
                                        Text(tool.permission.status).foregroundStyle(ClaudePalette.secondary)
                                            .fixedSize()
                                    }
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 8) {
                                            icon(connector)
                                            Text(tool.name)
                                        }
                                        Text(tool.permission.status).foregroundStyle(ClaudePalette.secondary)
                                    }.frame(maxWidth: .infinity, alignment: .leading)
                                }
                                chevron
                            }.font(.system(size: 17)).padding(.horizontal, 16).padding(.vertical, 16).contentShape(
                                Rectangle())
                        }.buttonStyle(.plain).accessibilityIdentifier("settings.connector.tool." + tool.id)
                    }
                }
            }
        }
        private func policy(connector: CodeConnector, tool: CodeConnectorTool?) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                RowGroup {
                    ForEach(Array(CodeToolPermission.allCases.enumerated()), id: \.element) { index, permission in
                        if index > 0 { Divider().padding(.horizontal, 16) }
                        Button {
                            if let tool {
                                action(
                                    .requestPermission(connector: connector.id, tool: tool.id, permission: permission))
                            } else {
                                action(.requestAllPermissions(connector: connector.id, permission: permission))
                            }
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(permission.rawValue).font(.system(size: 17))
                                    Text(permission.detail).font(.system(size: 13.3)).foregroundStyle(
                                        ClaudePalette.secondary
                                    ).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                                }.frame(maxWidth: .infinity, alignment: .leading)
                                if (tool?.permission ?? connector.commonPermission) == permission {
                                    Image(systemName: "checkmark").font(.system(size: 21, weight: .medium))
                                        .foregroundStyle(ClaudeSettingsColors.switchTint)
                                }
                            }.padding(16).contentShape(Rectangle())
                        }.buttonStyle(.plain).accessibilityIdentifier(
                            "settings.connector.policy." + permission.rawValue
                        ).accessibilityAddTraits(
                            (tool?.permission ?? connector.commonPermission) == permission ? [.isSelected] : [])
                    }
                }
                if tool != nil && !state.toolDescription.isEmpty {
                    Text(state.toolDescription).font(.system(size: 13.3)).foregroundStyle(ClaudePalette.secondary)
                        .lineSpacing(2).padding(.horizontal, 16)
                }
            }
        }
        @ViewBuilder private func icon(_ connector: CodeConnector) -> some View {
            if let iconContent {
                iconContent(connector).frame(width: 24, height: 24)
            } else {
                Image(systemName: connector.symbol).font(.system(size: 20)).frame(width: 24, height: 24)
            }
        }
        private var chevron: some View {
            Image(systemName: "chevron.right").font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary)
        }
    }
#endif
