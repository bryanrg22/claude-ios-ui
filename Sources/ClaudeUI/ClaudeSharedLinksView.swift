#if canImport(UIKit)
    import SwiftUI

    struct ClaudeSharedLinksView: View {
        let state: ClaudeSharedLinksState
        let action: (ClaudeSharedLinksAction) -> Void
        var body: some View {
            if let snapshot = state.selected { detail(snapshot) } else { list }
        }
        private var list: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    ForEach(state.groups) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(group.title).font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary).padding(
                                .horizontal, 16)
                            RowGroup {
                                ForEach(Array(group.snapshots.enumerated()), id: \.element.id) { index, snapshot in
                                    if index > 0 { Divider().padding(.horizontal, 16) }
                                    Button {
                                        action(.open(snapshot.id))
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(snapshot.title).font(.system(size: 17)).lineLimit(1)
                                            Text(snapshot.sharedLabel).font(.system(size: 13.3)).foregroundStyle(
                                                ClaudePalette.secondary)
                                        }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 16)
                                            .padding(.vertical, 16).contentShape(Rectangle())
                                    }.buttonStyle(.plain).accessibilityIdentifier("settings.shared.row." + snapshot.id)
                                }
                            }
                        }
                    }
                }.padding(.horizontal, 16).padding(.top, 36).padding(.bottom, 24)
            }.accessibilityIdentifier("settings.shared.list")
        }
        private func detail(_ snapshot: ClaudeSharedSnapshot) -> some View {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        ForEach(snapshot.messages) { message in
                            if message.role == .user {
                                HStack {
                                    Spacer(minLength: 36)
                                    Text(message.text).font(.system(size: 18)).padding(.horizontal, 16).padding(
                                        .vertical, 14
                                    ).background(
                                        ClaudePalette.adaptive(light: 0.92, dark: 0.165), in: .rect(cornerRadius: 28))
                                }
                            } else {
                                ClaudeMarkdownView(message.text) { action(.markdown($0)) }.frame(
                                    maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }.padding(.horizontal, 16).padding(.top, 30).padding(.bottom, 12)
                }.accessibilityIdentifier("settings.shared.detail")
                Text(
                    "Shared snapshot may contain attachments and data not displayed here which may have altered Claude’s responses"
                )
                .font(.system(size: 13)).foregroundStyle(ClaudePalette.secondary).multilineTextAlignment(.center).frame(
                    maxWidth: .infinity
                ).padding(.horizontal, 8).padding(.top, 8).padding(.bottom, 16).background(.bar).overlay(
                    alignment: .top
                ) { Divider() }.accessibilityIdentifier("settings.shared.disclaimer")
            }
        }
    }
#endif
