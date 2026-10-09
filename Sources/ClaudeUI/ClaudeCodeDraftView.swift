#if canImport(UIKit)
    import SwiftUI

    struct ClaudeCodeDraftView: View {
        @Binding var state: CodeDraftState
        let back: () -> Void
        let action: (CodeDraftAction) -> Void
        @State private var models = false
        @State private var environments = false
        @State private var repositories = false
        @State private var branches = false
        @State private var context = false
        @FocusState private var focused: Bool
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Button(action: back) {
                        Image(systemName: "chevron.left").font(.system(size: 23, weight: .light)).frame(
                            width: 44, height: 44)
                    }.glassEffect(in: .circle).accessibilityLabel("Back").accessibilityIdentifier("code.draft.back")
                    Spacer()
                }.frame(height: 48).padding(.horizontal, 16).padding(.top, -2)
                GeometryReader { geo in
                    VStack(spacing: 18) {
                        SleepingCodeMascot().frame(width: 64, height: 60)
                        Text(state.greetingName.isEmpty ? "Back at it" : "Back at it, \(state.greetingName)").font(
                            .custom("Newsreader16pt-Regular", size: 25)
                        ).foregroundStyle(ClaudePalette.adaptive(light: 0.24, dark: 0.76))
                    }.frame(maxWidth: .infinity).position(x: geo.size.width / 2, y: geo.size.height * 0.505)
                }
                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Button {
                            action(.chooseEnvironment)
                            environments = true
                        } label: {
                            Label(state.environment, systemImage: "cloud").font(.system(size: 16)).padding(
                                .horizontal, 10
                            ).frame(height: 40)
                        }.glassEffect(in: .capsule).accessibilityIdentifier("code.draft.environment")
                        Menu {
                            Button {
                                action(.changeBranch)
                                branches = true
                            } label: {
                                Label {
                                    Text("Change branch")
                                } icon: {
                                    CodeReferenceIcons.image(.branch)
                                }
                            }
                            Button {
                                action(.chooseRepository)
                                repositories = true
                            } label: {
                                Label {
                                    Text("Change repository")
                                } icon: {
                                    Image("GitHubLogo", bundle: .module)
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image("GitHubLogo", bundle: .module).resizable().frame(width: 18, height: 18)
                                Text(state.repository.map { "\($0.name) · \($0.branch)" } ?? "Add repository")
                                    .lineLimit(1)
                            }.font(.system(size: 16)).padding(.horizontal, 10).frame(height: 40)
                        }.menuOrder(.fixed).glassEffect(in: .capsule).accessibilityIdentifier("code.draft.repository")
                        Spacer(minLength: 0)
                    }
                    VStack(spacing: 14) {
                        TextField(
                            "Describe a task or ask a question...",
                            text: Binding(get: { state.text }, set: { action(.edit($0)) }), axis: .vertical
                        ).font(.system(size: 18)).lineLimit(1...16).fixedSize(horizontal: false, vertical: true)
                            .focused($focused).padding(.horizontal, 4).padding(.top, 3).accessibilityIdentifier(
                                "code.draft.text")
                        HStack(spacing: 8) {
                            Button {
                                action(.attach)
                                context = true
                            } label: {
                                Image(systemName: "plus").font(.system(size: 23, weight: .light)).frame(
                                    width: 36, height: 36
                                ).background(ClaudePalette.ink.opacity(0.08), in: .circle)
                            }.accessibilityLabel("Add attachment").accessibilityIdentifier("code.draft.attach")
                            Button {
                                models = true
                            } label: {
                                HStack(spacing: 4) {
                                    Text(state.model.rawValue).foregroundStyle(ClaudePalette.ink)
                                    Text(state.effort.rawValue).foregroundStyle(ClaudePalette.secondary)
                                }.font(.system(size: 14)).padding(.horizontal, 16).frame(height: 36).background(
                                    ClaudePalette.ink.opacity(0.08), in: .capsule)
                            }.accessibilityIdentifier("code.draft.model")
                            Spacer(minLength: 0)
                            Button {
                                action(.dictate)
                            } label: {
                                Image(systemName: "mic").font(.system(size: 19, weight: .light)).frame(
                                    width: 36, height: 36
                                ).background(ClaudePalette.ink.opacity(0.08), in: .circle)
                            }.accessibilityLabel("Dictate").accessibilityIdentifier("code.draft.dictate")
                            Button {
                                action(.submit(state))
                            } label: {
                                Image(systemName: "arrow.up").font(.system(size: 19)).frame(width: 36, height: 36)
                                    .background(ClaudePalette.orange, in: .circle)
                            }.disabled(!state.canSubmit).opacity(state.canSubmit ? 1 : 0.45).accessibilityLabel(
                                "Send task"
                            ).accessibilityIdentifier("code.draft.send")
                        }.buttonStyle(.plain)
                    }.padding(8).background(ClaudePalette.composer, in: .rect(cornerRadius: 28)).overlay {
                        RoundedRectangle(cornerRadius: 28).stroke(.white.opacity(0.12), lineWidth: 0.5)
                    }
                }.padding(.horizontal, 8)
            }.foregroundStyle(ClaudePalette.ink).background(ClaudePalette.background)
                .sheet(isPresented: $models) { ClaudeCodeModelSheet(state: $state, action: action) }
                .sheet(isPresented: $environments) { ClaudeCodeEnvironmentSheet(state: $state, action: action) }
                .sheet(isPresented: $repositories) { ClaudeCodeRepositorySheet(state: $state, action: action) }
                .sheet(isPresented: $branches) { ClaudeCodeBranchSheet(state: $state, action: action) }
                .sheet(isPresented: $context) {
                    ClaudeCodeContextSheet(
                        state: $state, action: { action(.context($0)) }, connectorAction: { action(.connectors($0)) })
                }
        }
    }
    struct ClaudeCodeModelSheet: View {
        @Binding var state: CodeDraftState
        let action: (CodeDraftAction) -> Void
        @State private var effort = false
        @Environment(\.dismiss) private var dismiss
        private let models: [ClaudeModel] = [.opus, .fable, .sonnet, .haiku]
        var body: some View {
            VStack(spacing: 0) {
                SheetHeader(
                    title: effort ? "Effort" : "Select model", back: effort, controlDiameter: 44,
                    close: { if effort { effort = false } else { dismiss() } }
                ).padding(.bottom, 18)
                if effort {
                    VStack(spacing: 9) {
                        RowGroup {
                            ForEach(CodeEffort.allCases, id: \.self) { level in
                                SheetRow(
                                    title: level.rawValue, checked: level == state.effort,
                                    badge: level == .medium ? "Recommended" : level == .max ? "3.5× or more usage" : nil
                                ) {
                                    action(.selectEffort(level))
                                    effort = false
                                }.accessibilityIdentifier("code.effort.\(level.rawValue)")
                                if level != .ultracode { RowDivider() }
                            }
                        }
                        Text(
                            "Higher effort means more thorough responses, but takes longer and uses your limits faster."
                        ).font(.system(size: 13)).foregroundStyle(ClaudePalette.secondary).fixedSize(
                            horizontal: false, vertical: true
                        ).padding(.horizontal, 16)
                    }.padding(.horizontal, 16)
                } else {
                    RowGroup {
                        ForEach(models, id: \.self) { model in
                            SheetRow(title: model.rawValue, detail: model.detail, checked: model == state.model) {
                                action(.selectModel(model))
                                dismiss()
                            }.accessibilityIdentifier("code.model.\(model.rawValue)")
                            if model != .haiku { RowDivider() }
                        }
                    }.padding(.horizontal, 16)
                    RowGroup {
                        SheetRow(title: "Effort", value: state.effort.rawValue, chevron: true) { effort = true }
                            .accessibilityIdentifier("code.model.effort")
                    }.padding(.horizontal, 16).padding(.top, 18)
                }
                Spacer(minLength: 0)
            }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink).presentationDetents([.height(415)]
            ).presentationDragIndicator(.visible).presentationCornerRadius(38)
        }
    }
    /// A static original pixel drawing following the captured sleeping silhouette.
    /// No animation timing or original sprite asset is asserted.
    private struct SleepingCodeMascot: View {
        var body: some View {
            Canvas { context, size in
                let sx = size.width / 64, sy = size.height / 60
                func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ color: Color) {
                    context.fill(Path(CGRect(x: x * sx, y: y * sy, width: w * sx, height: h * sy)), with: .color(color))
                }
                let orange = Color(red: 0.82, green: 0.45, blue: 0.32), gray = Color(white: 0.54),
                    eye = Color(white: 0.08)
                for x: CGFloat in [22, 40] {
                    rect(x, 0, 10, 3, gray)
                    rect(x + 6, 3, 4, 3, gray)
                    rect(x + 3, 6, 4, 3, gray)
                    rect(x, 9, 10, 3, gray)
                }
                rect(12, 23, 20, 31, orange)
                rect(30, 20, 23, 34, orange)
                rect(2, 38, 62, 10, orange)
                for x: CGFloat in [12, 22, 40, 49] { rect(x, 52, 5, 7, orange) }
                for x: CGFloat in [18, 44] {
                    rect(x, 38, 3, 5, eye)
                    rect(x + 4, 38, 3, 5, eye)
                    rect(x, 41, 7, 3, eye)
                }
            }.accessibilityHidden(true)
        }
    }
#endif
