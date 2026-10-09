#if canImport(UIKit)
import SwiftUI

struct ClaudeMemoryFilesView: View {
    let state: ClaudeMemoryFilesState
    let action: (ClaudeMemoryFilesAction) -> Void
    private var memoryTheme: ClaudeMarkdownTheme {
        var theme = ClaudeMarkdownTheme(); theme.bodyFont = .system(size: 17); theme.headingFonts = [28, 25, 22, 20, 19, 18].map { .system(size: $0, weight: .semibold) }; theme.lineSpacing = 5; theme.listSpacing = 16; return theme
    }
    var body: some View {
        ScrollView {
            if let file = state.selected {
                VStack(alignment: .leading, spacing: 16) {
                    if !file.summary.isEmpty { Text(file.summary).font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary).lineSpacing(4) }
                    ClaudeMarkdownView(file.markdown, theme: memoryTheme) { action(.markdown($0)) }
                }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 16).padding(.top, 26).padding(.bottom, 120)
            } else {
                VStack(alignment: .leading, spacing: 26) {
                    ForEach(state.groups) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(group.title).font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary).padding(.horizontal, 16)
                            RowGroup { ForEach(Array(group.files.enumerated()), id: \.element.id) { index, file in
                                if index > 0 { Divider().padding(.horizontal, 16) }
                                Button { action(.open(file.id)) } label: {
                                    HStack { VStack(alignment: .leading, spacing: 4) { Text(file.title).font(.system(size: 17)); Text(file.updatedLabel).font(.system(size: 13.3)).foregroundStyle(ClaudePalette.secondary) }.frame(maxWidth: .infinity, alignment: .leading); Image(systemName: "chevron.right").font(.system(size: 16)).foregroundStyle(ClaudePalette.secondary) }.padding(16).contentShape(Rectangle())
                                }.buttonStyle(.plain).accessibilityIdentifier("settings.memory.file." + file.id)
                            } }
                        }
                    }
                }.padding(.horizontal, 16).padding(.top, 36).padding(.bottom, 120)
            }
        }.accessibilityIdentifier("settings.memory.scroll").overlay(alignment: .bottom) { composer.padding(.horizontal, 16).padding(.bottom, 0) }
            .alert("Delete \(state.deletionCandidate?.title ?? "file")?", isPresented: Binding(get: { state.deletionCandidate != nil }, set: { if !$0 { action(.cancelDelete) } })) {
                Button("Cancel", role: .cancel) { action(.cancelDelete) }
                Button("Delete", role: .destructive) { action(.confirmDelete) }
            } message: { Text("Claude will no longer have access to the memories in this file. This can’t be undone.") }
    }
    private var composer: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                if state.draft.isEmpty { Text(state.selected == nil ? "Tell Claude what to remember" : "Tell Claude what to change or remove").font(.system(size: 17)).foregroundStyle(ClaudePalette.secondary).accessibilityHidden(true) }
                ClaudeMemoryDraftEditor(text: state.draft, placeholder: state.selected == nil ? "Tell Claude what to remember" : "Tell Claude what to change or remove") { action(.editDraft($0)) }.id((state.selected?.id ?? "memory-list") + String(state.editorRevision))
            }
            HStack { Spacer(); Button { action(.submitInstruction(fileID: state.selected?.id, text: state.draft)) } label: { Image(systemName: "arrow.up").font(.system(size: 19)).frame(width: 36, height: 36).foregroundStyle(.white).background(ClaudePalette.orange, in: .circle) }.disabled(state.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty).opacity(state.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1).accessibilityLabel("Send memory instruction").accessibilityIdentifier("settings.memory.send") }
        }.padding(12).glassEffect(.regular, in: .rect(cornerRadius: 28))
    }
}
#endif
