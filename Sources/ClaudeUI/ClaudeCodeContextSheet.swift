#if canImport(UIKit)
    import SwiftUI

    struct ClaudeCodeBranchSheet: View {
        @Binding var state: CodeDraftState
        let action: (CodeDraftAction) -> Void
        @State private var query = ""
        @Environment(\.dismiss) private var dismiss
        private var branches: [CodeBranch] {
            state.availableBranches.filter { query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) }
        }
        var body: some View {
            VStack(spacing: 20) {
                SheetHeader(title: "Choose base branch", controlDiameter: 44, close: { dismiss() })
                RowGroup {
                    ForEach(Array(branches.enumerated()), id: \.element.id) { index, branch in
                        SheetRow(
                            title: branch.name, detail: branch.isDefault ? "Default" : nil,
                            checked: state.repository?.branch == branch.name
                        ) {
                            action(.selectBranch(branch.id))
                            dismiss()
                        }.accessibilityIdentifier("code.branch.\(branch.id)")
                        if index < branches.count - 1 { RowDivider() }
                    }
                }.padding(.horizontal, 16)
                Spacer(minLength: 0)
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                    TextField("Search", text: $query).accessibilityIdentifier("code.branch.search")
                }.font(.system(size: 17)).padding(.horizontal, 14).frame(height: 46).glassEffect(in: .capsule).padding(
                    .horizontal, 28
                ).padding(.bottom, 14)
            }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink).presentationDetents([.height(415)]
            ).presentationDragIndicator(.visible).presentationCornerRadius(38)
        }
    }
    struct ClaudeCodeContextSheet: View {
        @Binding var state: CodeDraftState
        let action: (CodeContextAction) -> Void
        let connectorAction: (CodeConnectorAction) -> Void
        @State private var connectors = false
        @State private var permission = false
        @Environment(\.dismiss) private var dismiss
        var body: some View {
            VStack(spacing: 16) {
                if connectors {
                    ClaudeCodeConnectorsView(
                        state: $state.connectors, back: { connectors = false }, action: connectorAction)
                } else {
                    SheetHeader(
                        title: permission ? "Select mode" : "Add context", back: permission,
                        trailing: permission ? nil : "Photos", controlDiameter: 44,
                        close: { if permission { permission = false } else { dismiss() } },
                        trailingAction: { action(.photos) })
                    if permission {
                        RowGroup {
                            ForEach(CodePermission.allCases, id: \.self) { mode in
                                Button {
                                    action(.selectPermission(mode))
                                    permission = false
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(
                                            systemName: mode == .auto
                                                ? "bolt"
                                                : mode == .acceptEdits
                                                    ? "chevron.left.forwardslash.chevron.right" : "list.clipboard"
                                        ).font(.system(size: 20, weight: .light)).frame(width: 23).foregroundStyle(
                                            mode == .auto
                                                ? ClaudePalette.orange : mode == .acceptEdits ? .purple : .blue)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(mode.rawValue).font(.system(size: 16))
                                            Text(
                                                mode == .auto
                                                    ? "Claude handles permission decisions"
                                                    : mode == .acceptEdits
                                                        ? "Automatically accept all file edits"
                                                        : "Create a plan before making changes"
                                            ).font(.system(size: 13)).foregroundStyle(ClaudePalette.secondary)
                                        }.frame(maxWidth: .infinity, alignment: .leading)
                                        if mode == state.permission {
                                            Image(systemName: "checkmark").foregroundStyle(.blue)
                                        }
                                    }.padding(.horizontal, 16).padding(.vertical, 14).contentShape(.rect)
                                }.buttonStyle(.plain).accessibilityIdentifier("code.permission.\(mode.rawValue)")
                                if mode != .plan { RowDivider() }
                            }
                        }.padding(.horizontal, 16)
                    } else {
                        ScrollView(.horizontal) {
                            HStack(spacing: 8) {
                                Button {
                                    action(.camera)
                                } label: {
                                    VStack(spacing: 7) {
                                        Image(systemName: "camera").font(.system(size: 22))
                                        Text("Camera").font(.system(size: 17))
                                    }.frame(width: 100, height: 100).background(
                                        ClaudePalette.panel, in: .rect(cornerRadius: 28))
                                }.accessibilityIdentifier("code.context.camera")
                                ForEach(0..<3) { index in
                                    Button {
                                        action(.samplePhoto(index))
                                    } label: {
                                        SyntheticPhoto(index: index).frame(width: 100, height: 100).clipShape(
                                            .rect(cornerRadius: 28))
                                    }.accessibilityLabel("Sample landscape \(index + 1)")
                                }
                            }.padding(.horizontal, 16)
                        }.scrollIndicators(.hidden)
                        RowGroup { SheetRow(title: "Add files", symbol: "doc.badge.arrow.up") { action(.files) } }
                            .padding(.horizontal, 16)
                        RowGroup {
                            SheetRow(
                                title: "Permission", symbol: "bolt", value: state.permission.rawValue, chevron: true
                            ) { permission = true }.accessibilityIdentifier("code.context.permission")
                        }.padding(.horizontal, 16)
                        RowGroup {
                            SheetRow(title: "Connectors", symbol: "square.grid.2x2", chevron: true) {
                                action(.connectors)
                                connectors = true
                            }.accessibilityIdentifier("code.context.connectors")
                        }.padding(.horizontal, 16)
                    }
                    Spacer(minLength: 0)
                }
            }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink).presentationDetents([.height(415)]
            ).presentationDragIndicator(.visible).presentationCornerRadius(38)
        }
    }
#endif
