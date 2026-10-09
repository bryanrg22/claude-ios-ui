import Testing
@testable import ClaudeUI

@Suite struct ProjectStateTests {
    @Test func introductionMustContinueBeforeEditing() {
        var state = ProjectState()
        state.reduce(.begin)
        state.reduce(.editName("Ignored"))
        #expect(state.editor == .introduction)
        #expect(state.draft.name.isEmpty)
        #expect(!state.canCreate)
        state.reduce(.continueIntroduction)
        state.reduce(.editName("Garden"))
        #expect(state.canCreate)
    }
    @Test func cancellationResetsDraftAndPreservesHostProjects() {
        var state = ProjectState()
        let project = ClaudeProject(name: "Existing")
        state.projects = [project]
        state.reduce(.begin)
        state.reduce(.continueIntroduction)
        state.reduce(.editName("Unsent"))
        state.reduce(.editGoal("A goal"))
        state.reduce(.addContext("example/repo"))
        state.reduce(.selectEnvironment("Default"))
        state.reduce(.cancel)
        #expect(state.editor == nil)
        #expect(state.draft == ProjectDraft())
        #expect(state.projects == [project])
        state.reduce(.begin)
        #expect(state.editor == .setup)
        #expect(state.draft.name.isEmpty)
    }
    @Test func whitespaceInvalidAndValidPayloadIsTrimmed() {
        var state = ProjectState()
        state.reduce(.begin)
        state.reduce(.continueIntroduction)
        state.reduce(.editName(" \n "))
        #expect(!state.canCreate)
        #expect(state.validatedDraft == nil)
        state.reduce(.editName("  Garden plan \n"))
        state.reduce(.editGoal(" Seasonal planting "))
        #expect(state.validatedDraft?.name == "Garden plan")
        #expect(state.validatedDraft?.goal == "Seasonal planting")
        #expect(state.validatedDraft?.environment == nil)
    }
    @Test func createIntentDoesNotFabricateAProjectOrClearDraft() {
        var state = ProjectState()
        state.reduce(.begin)
        state.reduce(.continueIntroduction)
        state.reduce(.editName("Garden"))
        let draft = state.validatedDraft!
        state.reduce(.create(draft))
        #expect(state.projects.isEmpty)
        #expect(state.editor == .setup)
        #expect(state.draft.name == "Garden")
    }
    @Test func contextDeduplicationAndEnvironmentAllowlist() {
        var state = ProjectState()
        state.reduce(.begin)
        state.reduce(.continueIntroduction)
        state.reduce(.addContext("example/repo"))
        state.reduce(.addContext("example/repo"))
        state.reduce(.addContext(" "))
        state.reduce(.selectEnvironment("Unknown"))
        #expect(state.draft.environment == nil)
        #expect(state.draft.context == ["example/repo"])
        state.reduce(.selectEnvironment("Default"))
        state.reduce(.removeContext("example/repo"))
        #expect(state.draft.context.isEmpty)
        #expect(state.draft.environment == "Default")
    }
    @Test func acknowledgmentUpsertsIdentityAndSessionsStaySeparate() {
        var state = ProjectState()
        let other = ProjectState()
        var project = ClaudeProject(name: "Garden")
        state.acknowledgeCreated(project)
        project.name = "Garden notes"
        state.acknowledgeCreated(project)
        #expect(state.projects == [project])
        #expect(other.projects.isEmpty)
        #expect(state.editor == nil)
    }
    @Test func iconSearchAndUnknownSelectionDoNotCorruptDraft() {
        var state = ProjectState()
        state.reduce(.begin)
        state.reduce(.continueIntroduction)
        state.reduce(.selectIcon("invalid.symbol"))
        state.reduce(.selectIconColor("Invisible"))
        #expect(state.draft.icon == "rectangle.stack")
        #expect(state.draft.iconColor == "Default")
        #expect(ProjectIconOption.matching("  BOOK  ").contains { $0.symbol == "book" })
        #expect(ProjectIconOption.matching("unlikely-symbol-123").isEmpty)
        #expect(Set(ProjectIconOption.options.map(\.id)).count == ProjectIconOption.options.count)
    }
    @Test func projectFiltersUseInjectedOwnershipAndHideArchived() {
        var state = ProjectState()
        var mine = ClaudeProject(name: "Mine")
        mine.pinned = true
        var shared = ClaudeProject(name: "Shared")
        shared.owned = false
        shared.pinned = true
        var archived = ClaudeProject(name: "Archived")
        archived.archived = true
        archived.pinned = true
        state.projects = [mine, shared, archived]
        #expect(state.visibleProjects == [mine])
        state.reduce(.selectFilter(.pinned))
        #expect(state.visibleProjects == [mine, shared])
    }
    @Test func projectsRoutesAreExclusiveAndPreserveConversationDraft() {
        var state = SessionState()
        state.draft = "Unsent conversation"
        state.reduce(.openProjects)
        #expect(state.showingProjects)
        #expect(!state.showingCode)
        #expect(!state.showingDispatch)
        state.reduce(.projects(.begin))
        state.reduce(.projects(.continueIntroduction))
        state.reduce(.projects(.editName("Garden")))
        #expect(state.projects.canCreate)
        #expect(state.draft == "Unsent conversation")
        state.reduce(.openCode)
        #expect(!state.showingProjects)
        #expect(state.showingCode)
        state.reduce(.openProjects)
        #expect(state.projects.draft.name == "Garden")
        state.reduce(.newSession)
        #expect(!state.showingProjects)
        #expect(state.projects.editor == nil)
        #expect(state.projects.hasSeenIntroduction)
    }
}
