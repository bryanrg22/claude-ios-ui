import Testing
@testable import ClaudeUI

@Test func artifactFiltersIntersectAndPreserveData() {
    var state = ArtifactsState(); state.items = [.init(id: "a", title: "Garden notes", pinned: true), .init(id: "b", title: "Garden design", kind: .design, owned: false), .init(id: "c", title: "Book notes")]
    let items = state.items
    state.reduce(.ownership(.pinned)); #expect(state.visibleItems.map(\.id) == ["a"])
    state.reduce(.ownership(.shared)); #expect(state.visibleItems.map(\.id) == ["b"])
    state.reduce(.kind(.docs)); #expect(state.visibleItems.isEmpty)
    state.reduce(.ownership(.yours)); state.reduce(.search("GARDEN")); #expect(state.visibleItems.map(\.id) == ["a"])
    state.reduce(.ownership(.all)); state.reduce(.kind(.all)); state.reduce(.search("")); #expect(state.visibleItems == items)
    for kind in ArtifactKind.allCases { state.reduce(.kind(kind)); #expect(state.visibleItems.allSatisfy { kind == .all || $0.kind == kind }) }
    #expect(state.items == items)
}
@Test func artifactDocumentCollapsesAreScopedAndResetOnNavigation() {
    var state = ArtifactsState(); state.items = [.init(id: "a", title: "A", document: .init(title: "A", sections: [.init(id: "s", title: "S", paragraphs: ["Body"])])), .init(id: "b", title: "B")]
    state.reduce(.open("missing")); #expect(state.selectedID == nil)
    state.reduce(.toggleTitle); state.reduce(.toggleSection("s")); #expect(!state.titleCollapsed); #expect(state.collapsedSections.isEmpty)
    state.reduce(.open("a")); state.reduce(.toggleSection("unknown")); #expect(state.collapsedSections.isEmpty)
    state.reduce(.toggleSection("s")); #expect(state.collapsedSections == ["s"]); state.reduce(.toggleTitle); #expect(state.titleCollapsed)
    state.reduce(.close); #expect(state.selectedID == nil); #expect(state.collapsedSections.isEmpty); #expect(!state.titleCollapsed)
    state.reduce(.open("b")); state.reduce(.toggleTitle); #expect(!state.titleCollapsed)
}
@Test func artifactShareHistoryCommentsAndTabsAreInertHostIntents() {
    var state = ArtifactsState(); state.items = [.init(id: "a", title: "A")]; state.reduce(.open("a")); let original = state
    for action: ArtifactAction in [.share("a"), .comments("a"), .tabs("a"), .undo("a"), .redo("a")] { state.reduce(action); #expect(state == original) }
}
@Test func artifactsRouteIsolatesChatAndClosesDocumentOnNewSession() {
    var state = SessionState(); state.draft = "Keep chat draft"; state.artifacts.items = [.init(id: "a", title: "A")]
    state.reduce(.openArtifacts); #expect(state.showingArtifacts); #expect(!state.showingProjects); #expect(!state.showingCode); #expect(state.draft == "Keep chat draft")
    state.reduce(.openProjects); #expect(!state.showingArtifacts); state.reduce(.openArtifacts); state.reduce(.artifacts(.open("a")))
    state.reduce(.newSession); #expect(!state.showingArtifacts); #expect(state.artifacts.items.count == 1); #expect(state.artifacts.selectedID == nil)
}
