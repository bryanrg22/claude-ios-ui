#if canImport(UIKit)
    import SwiftUI

    struct ClaudeCodeEnvironmentSheet: View {
        @Binding var state: CodeDraftState
        let action: (CodeDraftAction) -> Void
        @Environment(\.dismiss) private var dismiss
        var body: some View {
            VStack(spacing: 20) {
                SheetHeader(title: "Choose environment", controlDiameter: 44, close: { dismiss() })
                    .overlay(alignment: .trailing) {
                        Button {
                            action(.environment(.help))
                        } label: {
                            Image(systemName: "questionmark.circle").font(.system(size: 19)).frame(
                                width: 44, height: 44)
                        }.glassEffect(in: .circle).padding(.trailing, 16).padding(.top, 7).accessibilityLabel(
                            "Environment help")
                    }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Cloud environments").font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary).padding(
                        .horizontal, 16)
                    RowGroup {
                        ForEach(Array(state.environments.enumerated()), id: \.element.id) { index, environment in
                            SheetRow(
                                title: environment.name, symbol: "cloud",
                                checked: state.selectedEnvironmentID == environment.id
                            ) {
                                action(.selectEnvironment(environment.id))
                                dismiss()
                            }.accessibilityIdentifier("code.environment.\(environment.id)")
                            if index < state.environments.count - 1 { RowDivider() }
                        }
                    }
                    RowGroup {
                        SheetRow(title: "Create environment", symbol: "plus") { action(.environment(.begin)) }
                            .accessibilityIdentifier("code.environment.create")
                    }.padding(.top, 6)
                }.padding(.horizontal, 16).padding(.top, 14)
                Spacer(minLength: 0)
            }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink).presentationDetents([.height(415)]
            ).presentationDragIndicator(.visible).presentationCornerRadius(38)
                .sheet(
                    isPresented: Binding(
                        get: { state.environmentForm.presented }, set: { if !$0 { action(.environment(.cancel)) } })
                ) { ClaudeCodeEnvironmentEditor(state: $state.environmentForm) { action(.environment($0)) } }
        }
    }
    struct ClaudeCodeEnvironmentEditor: View {
        @Binding var state: CodeEnvironmentFormState
        let action: (CodeEnvironmentAction) -> Void
        var body: some View {
            VStack(spacing: 0) {
                SheetHeader(
                    title: "New cloud environment", controlDiameter: 44, titleMaxWidth: 275, close: { action(.cancel) })
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            label("Name")
                            TextField(
                                "Default", text: Binding(get: { state.draft.name }, set: { action(.editName($0)) })
                            ).font(.system(size: 16)).padding(.horizontal, 16).frame(height: 48).background(
                                ClaudePalette.panel, in: .capsule
                            ).overlay { Capsule().stroke(ClaudePalette.ink.opacity(0.15), lineWidth: 0.5) }
                                .accessibilityIdentifier("code.environment.name")
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            label("Network access")
                            Menu {
                                ForEach(CodeNetworkAccess.allCases, id: \.self) { network in
                                    Button {
                                        action(.selectNetwork(network))
                                    } label: {
                                        Text(network.rawValue)
                                        Text(network.detail)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(state.draft.network.rawValue)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                }.font(.system(size: 16)).padding(.horizontal, 16).frame(height: 48).background(
                                    ClaudePalette.panel, in: .capsule
                                ).overlay { Capsule().stroke(ClaudePalette.ink.opacity(0.15), lineWidth: 0.5) }
                            }.accessibilityIdentifier("code.environment.network")
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            label("Environment variables")
                            ZStack(alignment: .topLeading) {
                                if state.draft.variables.isEmpty {
                                    Text("EXAMPLE_KEY=sample-value").font(.system(size: 16)).foregroundStyle(
                                        ClaudePalette.secondary
                                    ).padding(16).allowsHitTesting(false)
                                }
                                TextEditor(
                                    text: Binding(get: { state.draft.variables }, set: { action(.editVariables($0)) })
                                ).font(.system(size: 16)).scrollContentBackground(.hidden).padding(10)
                                    .accessibilityIdentifier("code.environment.variables")
                            }.frame(height: 138).background(ClaudePalette.panel, in: .rect(cornerRadius: 26)).overlay {
                                RoundedRectangle(cornerRadius: 26).stroke(
                                    ClaudePalette.ink.opacity(0.15), lineWidth: 0.5)
                            }
                            HStack(spacing: 0) {
                                Text("In ")
                                Button {
                                    action(.formatHelp)
                                } label: {
                                    Text(".env format").underline()
                                }
                                Text(".")
                            }.font(.system(size: 14)).foregroundStyle(ClaudePalette.secondary).padding(.horizontal, 16)
                        }
                    }.padding(.horizontal, 16).padding(.top, 6)
                }.scrollDismissesKeyboard(.interactively)
                Button {
                    action(.create(state.draft))
                } label: {
                    Text("Create environment").font(.system(size: 18, weight: .semibold)).foregroundStyle(.black).frame(
                        maxWidth: .infinity
                    ).frame(height: 48).background(
                        .white.opacity(
                            state.draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1),
                        in: .capsule)
                }.disabled(state.draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty).padding(
                    .horizontal, 16
                ).padding(.bottom, 16).accessibilityIdentifier("code.environment.submit")
            }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink).presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        private func label(_ title: String) -> some View {
            Text(title).font(.system(size: 16)).foregroundStyle(ClaudePalette.secondary).padding(.horizontal, 16)
        }
    }
    struct ClaudeCodeRepositorySheet: View {
        @Binding var state: CodeDraftState
        let action: (CodeDraftAction) -> Void
        @Environment(\.dismiss) private var dismiss
        var body: some View {
            VStack(spacing: 0) {
                SheetHeader(
                    title: "Repositories (\(state.repository == nil ? 0 : 1))", controlDiameter: 44,
                    close: { dismiss() })
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if let selected = state.repository {
                            section("Selected")
                            RowGroup { row(selected, selected: true) }
                        }
                        section("Repositories").padding(.top, 12)
                        RowGroup {
                            ForEach(
                                Array(state.repositories.filter { $0.id != state.repository?.id }.enumerated()),
                                id: \.element.id
                            ) { index, repository in
                                row(repository, selected: false)
                                if index < state.repositories.filter({ $0.id != state.repository?.id }).count - 1 {
                                    RowDivider()
                                }
                            }
                        }
                    }.padding(.horizontal, 16).padding(.top, 28).padding(.bottom, 65)
                }.scrollIndicators(.hidden)
            }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink).presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .overlay(alignment: .bottom) {
                    HStack {
                        Button {
                            action(.searchRepositories)
                        } label: {
                            Image(systemName: "magnifyingglass").font(.system(size: 20, weight: .light)).frame(
                                width: 44, height: 44)
                        }.glassEffect(in: .circle).accessibilityLabel("Search repositories").accessibilityIdentifier(
                            "code.repositories.search")
                        Spacer()
                        Button {
                            action(.connectRepositories)
                        } label: {
                            Label("Connect more", systemImage: "plus").font(.system(size: 16)).padding(.horizontal, 16)
                                .frame(height: 44)
                        }.glassEffect(in: .capsule).accessibilityIdentifier("code.repositories.connect")
                    }.padding(.horizontal, 24).padding(.bottom, 0)
                }
        }
        private func section(_ title: String) -> some View {
            Text(title).font(.system(size: 16)).foregroundStyle(ClaudePalette.secondary).padding(.horizontal, 16)
        }
        private func row(_ repository: CodeRepository, selected: Bool) -> some View {
            Button {
                action(.selectRepository(repository.id))
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(repository.owner).font(.system(size: 14)).foregroundStyle(ClaudePalette.secondary)
                        Text(repository.name).font(.system(size: 18))
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    if selected {
                        Image(systemName: "checkmark").font(.system(size: 20, weight: .semibold)).foregroundStyle(.blue)
                    }
                }.padding(.horizontal, 16).padding(.vertical, 14).contentShape(.rect)
            }.buttonStyle(.plain).accessibilityIdentifier("code.repository.\(repository.id)")
        }
    }
#endif
