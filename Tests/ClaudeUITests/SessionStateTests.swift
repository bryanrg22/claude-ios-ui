import Testing
@testable import ClaudeUI

@Test func blankSendAndReentrantSendAreIgnored() {
    var state = SessionState()
    state.reduce(.send("  \n"))
    #expect(state.messages.isEmpty)
    state.reduce(.send("hello"))
    state.reduce(.send("duplicate"))
    #expect(state.messages.count == 1)
    #expect(state.phase == .streaming)
}
@Test func streamingStopRejectsLateChunksAndRetainsPartialResponse() {
    var state = SessionState()
    state.draft = "hello"
    state.reduce(.send(state.draft))
    #expect(state.draft.isEmpty)
    let responseID = state.responseID!
    state.appendResponse("Hello", responseID: responseID)
    state.reduce(.stop)
    state.appendResponse(" late", responseID: responseID)
    #expect(state.messages.last?.text == "Hello")
    #expect(state.phase == .idle)
}
@Test func dictationCancelRestoresDraftAcrossPause() {
    var state = SessionState()
    state.draft = "Original draft"
    state.reduce(.startDictation)
    state.transcript = "new words"
    state.reduce(.stopDictation)
    #expect(state.phase == .recordingPaused)
    state.reduce(.cancelDictation)
    #expect(state.draft == "Original draft")
    #expect(state.transcript.isEmpty)
    #expect(state.phase == .idle)
}
@Test func dictationCommitCombinesWithoutSending() {
    var state = SessionState()
    state.draft = "Original"
    state.reduce(.startDictation)
    state.transcript = "new words"
    state.reduce(.commitDictation)
    #expect(state.draft == "Original new words")
    #expect(state.messages.isEmpty)
    #expect(state.canSend)
}
@Test func cannotRecordDuringResponse() {
    var state = SessionState()
    state.reduce(.send("Hi"))
    state.reduce(.startDictation)
    #expect(state.phase == .streaming)
}
@Test func newSessionResetsTransientStateButKeepsChoices() {
    var state = SessionState()
    state.model = .haiku
    state.effort = .low
    state.appearance = .light
    state.temporary = true
    state.reduce(.attach("photo.jpg"))
    state.reduce(.send(""))
    state.appendResponse("Hello", responseID: state.responseID!)
    state.reduce(.newSession)
    #expect(state.messages.isEmpty)
    #expect(state.attachments.isEmpty)
    #expect(state.phase == .idle)
    #expect(!state.temporary)
    #expect(state.model == .haiku)
    #expect(state.effort == .low)
    #expect(state.appearance == .light)
}
@Test func attachmentsDeduplicateAndCanSendWithoutText() {
    var state = SessionState()
    state.reduce(.attach("photo.jpg"))
    state.reduce(.attach("photo.jpg"))
    #expect(state.attachments.count == 1)
    #expect(state.canSend)
    state.reduce(.removeAttachment("photo.jpg"))
    #expect(!state.canSend)
}
@Test func retryReplacesAssistantAndFinishesCleanly() {
    var state = SessionState()
    state.reduce(.send("Hello"))
    state.appendResponse("Hi", responseID: state.responseID!)
    state.finishResponse(responseID: state.responseID!)
    state.reduce(.retry)
    #expect(state.messages.count == 1)
    state.appendResponse("Hey", responseID: state.responseID!)
    state.finishResponse(responseID: state.responseID!)
    #expect(state.messages.last?.text == "Hey")
    #expect(state.phase == .idle)
}

@Test func staleChunksAndCompletionCannotContaminateANewerResponse() {
    var state = SessionState()
    state.reduce(.send("First"))
    let first = state.responseID!
    state.reduce(.stop)
    state.reduce(.send("Second"))
    let second = state.responseID!
    #expect(first != second)
    state.appendResponse("stale", responseID: first)
    state.finishResponse(responseID: first)
    #expect(state.messages.count == 2)
    #expect(state.phase == .streaming)
    state.appendResponse("Current", responseID: second)
    state.finishResponse(responseID: second)
    #expect(state.messages.last?.text == "Current")
    #expect(state.phase == .idle)
}
@Test func newSessionAndRetryInvalidateEarlierResponseTokens() {
    var state = SessionState()
    state.reduce(.send("First"))
    let first = state.responseID!
    state.reduce(.newSession)
    state.reduce(.send("Next"))
    let next = state.responseID!
    state.appendResponse("stale", responseID: first)
    #expect(state.messages.count == 1)
    state.appendResponse("answer", responseID: next)
    state.finishResponse(responseID: next)
    state.reduce(.retry)
    let retry = state.responseID!
    state.appendResponse("late answer", responseID: next)
    state.finishResponse(responseID: next)
    #expect(state.messages.count == 1)
    #expect(state.phase == .streaming)
    state.appendResponse("retry answer", responseID: retry)
    #expect(state.messages.last?.text == "retry answer")
}

@Test func cameraPhotoAndVideoStateDoesNotCaptureBeforeShutter() {
    var camera = CameraState()
    #expect(camera.mode == .photo)
    #expect(camera.flash == .auto)
    #expect(camera.reduce(.selectZoom(2)) == nil)
    camera.reduce(.flip)
    #expect(camera.reduce(.shutter) == CameraCapture(mode: .photo, zoom: 2, frontFacing: true))
    camera.reduce(.selectMode(.video))
    #expect(camera.reduce(.shutter) == nil)
    #expect(camera.recording)
    camera.reduce(.selectMode(.photo))
    camera.reduce(.flip)
    #expect(camera.mode == .video)
    #expect(camera.frontFacing)
    #expect(camera.reduce(.shutter)?.mode == .video)
    #expect(!camera.recording)
}
@Test func cameraCancelAbandonsRecordingAndRejectsInvalidZoom() {
    var camera = CameraState()
    camera.reduce(.selectZoom(9))
    #expect(camera.zoom == 1)
    camera.reduce(.cycleFlash)
    #expect(camera.flash == .on)
    camera.reduce(.cycleFlash)
    #expect(camera.flash == .off)
    camera.reduce(.cycleFlash)
    #expect(camera.flash == .auto)
    camera.reduce(.selectMode(.video))
    camera.reduce(.shutter)
    #expect(camera.reduce(.cancel) == nil)
    #expect(!camera.recording)
}

@Test func editCancellationRestoresOriginalConversationDraftAndAttachments() {
    var state = SessionState()
    state.reduce(.send("Original"))
    let response = state.responseID!
    state.appendResponse("Answer", responseID: response)
    state.finishResponse(responseID: response)
    let original = state.messages
    state.draft = "Unsent draft"
    state.attachments = ["notes.pdf"]
    state.reduce(.beginEditing(original[0].id))
    #expect(state.visibleMessages.count == 1)
    #expect(state.messages == original)
    state.draft = "Changed"
    state.attachments = ["replacement.jpg"]
    state.reduce(.cancelEditing)
    #expect(state.draft == "Unsent draft")
    #expect(state.attachments == ["notes.pdf"])
    #expect(state.messages == original)
    #expect(state.visibleMessages.count == 2)
}
@Test func committingAnEditTruncatesFutureAndRejectsOldResponse() {
    var state = SessionState()
    state.reduce(.send("Original"))
    let old = state.responseID!
    state.appendResponse("Answer", responseID: old)
    state.finishResponse(responseID: old)
    state.reduce(.send("Later question"))
    let later = state.responseID!
    state.appendResponse("Later answer", responseID: later)
    state.finishResponse(responseID: later)
    let target = state.messages[0].id
    state.reduce(.beginEditing(target))
    state.reduce(.send("Edited"))
    let edited = state.responseID!
    #expect(state.messages.count == 1)
    #expect(state.messages[0].id == target)
    #expect(state.messages[0].text == "Edited")
    #expect(state.editingMessageID == nil)
    state.appendResponse("stale", responseID: later)
    state.finishResponse(responseID: old)
    #expect(state.messages.count == 1)
    #expect(state.phase == .streaming)
    state.appendResponse("New answer", responseID: edited)
    #expect(state.messages.last?.text == "New answer")
}
@Test func newSessionDuringEditCannotRestoreOldDraftOrMessages() {
    var state = SessionState()
    state.messages = [.init(role: .user, text: "Original")]
    state.draft = "Unsent"
    state.reduce(.beginEditing(state.messages[0].id))
    state.reduce(.newSession)
    state.reduce(.cancelEditing)
    #expect(state.draft.isEmpty)
    #expect(state.messages.isEmpty)
    #expect(state.editingMessageID == nil)
}
@Test func invalidEditingTargetsAndBlankCommitAreNonDestructive() {
    var state = SessionState()
    state.messages = [.init(role: .assistant, text: "Answer")]
    state.draft = "Keep"
    state.reduce(.beginEditing(state.messages[0].id))
    #expect(state.draft == "Keep")
    #expect(state.editingMessageID == nil)
    state.messages.append(.init(role: .user, text: "Original"))
    state.reduce(.beginEditing(state.messages.last!.id))
    state.reduce(.send("   "))
    #expect(state.editingMessageID != nil)
    #expect(state.messages.last?.text == "Original")
    #expect(state.phase == .idle)
}

@Test func silentDictationStopReturnsIdleAndPreservesPriorDraft() {
    var state = SessionState()
    state.draft = "Keep draft"
    state.reduce(.startDictation)
    state.transcript = " \n "
    state.reduce(.stopDictation)
    #expect(state.phase == .idle)
    #expect(state.draft == "Keep draft")
    #expect(state.transcript.isEmpty)
    #expect(state.dictationLevels.isEmpty)
}
@Test func waveformNormalizesMalformedLevelsAndNeverExceedsItsUIBounds() {
    var state = SessionState()
    state.reduce(.startDictation)
    state.dictationLevels = [-1, 0, 0.5, 3, .nan, .infinity, -.infinity]
    #expect(state.dictationLevels == [0, 0, 0.5, 1, 0, 0, 0])
    let heights = DictationWaveformMetrics.barHeights(for: state.dictationLevels, count: 7)
    #expect(heights == [2.6, 2.6, 12, 24, 2.6, 2.6, 2.6])
    #expect(DictationWaveformMetrics.barHeights(for: [], count: 3) == [2.6, 2.6, 2.6])
    #expect(DictationWaveformMetrics.barHeights(for: [1], count: -1).isEmpty)
    #expect(DictationWaveformMetrics.barHeights(for: [1], count: 999).count == 256)
}
@Test func waveformLevelsClearOnCancellationCommitAndNewSession() {
    var state = SessionState()
    state.reduce(.startDictation)
    state.dictationLevels = [1, 0.5]
    state.reduce(.cancelDictation)
    #expect(state.dictationLevels.isEmpty)
    state.reduce(.startDictation)
    state.dictationLevels = [0.5]
    state.transcript = "Hello"
    state.reduce(.commitDictation)
    #expect(state.dictationLevels.isEmpty)
    state.reduce(.startDictation)
    state.dictationLevels = Array(repeating: 0.7, count: 300)
    #expect(state.dictationLevels.count == 256)
    state.reduce(.newSession)
    #expect(state.dictationLevels.isEmpty)
    #expect(state.phase == .idle)
}

@Test func voiceEntryExitPreservesConversationDraftAndAttachments() {
    var state = SessionState()
    state.messages = [.init(role: .user, text: "Hello"), .init(role: .assistant, text: "Hi")]
    state.draft = "Draft"
    state.attachments = ["notes.pdf"]
    let messages = state.messages
    state.reduce(.startVoice)
    #expect(state.voiceActive)
    state.reduce(.toggleVoiceInput)
    state.reduce(.toggleVoiceOutput)
    #expect(!state.voiceInputEnabled)
    #expect(state.voiceOutputMuted)
    state.reduce(.endVoice)
    #expect(!state.voiceActive)
    #expect(state.voiceInputEnabled)
    #expect(!state.voiceOutputMuted)
    #expect(state.messages == messages)
    #expect(state.draft == "Draft")
    #expect(state.attachments == ["notes.pdf"])
}
@Test func voiceGuardsIncompatibleModesAndPreservesPreferencesAcrossNewSession() {
    var state = SessionState()
    state.reduce(.startDictation)
    state.reduce(.startVoice)
    #expect(!state.voiceActive)
    state.reduce(.cancelDictation)
    state.messages = [.init(role: .user, text: "Original")]
    state.reduce(.beginEditing(state.messages[0].id))
    state.reduce(.startVoice)
    #expect(!state.voiceActive)
    state.reduce(.cancelEditing)
    state.reduce(.startVoice)
    state.reduce(.startDictation)
    #expect(state.phase == .idle)
    state.reduce(.beginEditing(state.messages[0].id))
    #expect(state.editingMessageID == nil)
    state.reduce(.selectVoice(.clara))
    state.reduce(.selectVoiceLanguage("English"))
    state.reduce(.newSession)
    #expect(!state.voiceActive)
    #expect(state.voice == .clara)
    #expect(state.voiceLanguage == "English")
}

@Test func deviceConnectionIsExplicitAndAccountIntentsDoNotPerformOperations() {
    var state = DeviceState()
    #expect(state.rows.isEmpty)
    state.rows = [.init(id: "sample", name: "Desktop")]
    #expect(state.rows[0].status == .unknown)
    let before = state
    for action: DeviceAction in [
        .logOutAllDevices, .requestDeleteAccount, .requestTab(.privacy), .openAPIDashboard, .chooseProfilePhoto,
        .copyOrganizationID
    ] { state.reduce(action) }
    #expect(state == before)
}
@Test func accountLoadIgnoresClosedAndReplacedRequests() {
    var state = DeviceState()
    state.reduce(.openManage)
    let old = state.accountRequestID!
    state.reduce(.closeManage)
    state.finishAccountLoad(.init(fullName: "Old"), requestID: old)
    #expect(state.accountLoad == .idle)
    #expect(state.profile.fullName.isEmpty)
    state.reduce(.openManage)
    let current = state.accountRequestID!
    state.failAccountLoad("stale", requestID: old)
    state.finishAccountLoad(.init(fullName: "Old"), requestID: old)
    #expect(state.accountLoad == .loading)
    state.finishAccountLoad(.init(fullName: "Jordan", nickname: "J"), requestID: current)
    #expect(state.accountLoad == .loaded)
    #expect(state.profile.fullName == "Jordan")
    #expect(state.accountRequestID == nil)
    state.failAccountLoad("duplicate", requestID: current)
    #expect(state.accountLoad == .loaded)
}
@Test func accountProfileEditingRequiresLoadedStateAndFailureCanRetry() {
    var state = DeviceState()
    state.reduce(.editProfile(.fullName, "Ignored"))
    #expect(state.profile.fullName.isEmpty)
    state.reduce(.openManage)
    let failed = state.accountRequestID!
    state.failAccountLoad("Unavailable", requestID: failed)
    #expect(state.accountLoad == .failed("Unavailable"))
    state.reduce(.editProfile(.nickname, "Ignored"))
    #expect(state.profile.nickname.isEmpty)
    state.reduce(.openManage)
    state.finishAccountLoad(.init(), requestID: state.accountRequestID!)
    state.reduce(.editProfile(.fullName, "Jordan"))
    state.reduce(.editProfile(.nickname, "J"))
    state.reduce(.editProfile(.work, "Engineering"))
    state.reduce(.editProfile(.instructions, "Brief answers"))
    #expect(state.profile.fullName == "Jordan")
    #expect(state.profile.nickname == "J")
    #expect(state.profile.work == "Engineering")
    #expect(state.profile.instructions == "Brief answers")
}
@Test func newConversationPreservesInjectedDeviceAndAccountState() {
    var state = SessionState()
    state.devices.rows = [.init(id: "sample", name: "Desktop", status: .connected)]
    state.reduce(.devices(.openManage))
    state.devices.finishAccountLoad(.init(fullName: "Jordan"), requestID: state.devices.accountRequestID!)
    let devices = state.devices
    state.draft = "Draft"
    state.reduce(.newSession)
    #expect(state.devices == devices)
    #expect(state.draft.isEmpty)
}

@Test func dispatchStatusIsInjectedAndSubmissionDoesNotInventRemoteWork() {
    var state = DispatchState()
    #expect(state.connection == .unknown)
    #expect(state.messages.isEmpty)
    state.draft = "Task"
    let before = state
    state.reduce(.submit(state.draft))
    state.reduce(.attach)
    #expect(state == before)
}
@Test func dispatchRejectsStaleLoadsAcrossClosingAndRetry() {
    var state = DispatchState()
    state.reduce(.reload)
    let old = state.loadID!
    state.reduce(.close)
    state.reduce(.reload)
    let next = state.loadID!
    state.finishLoading([.init(text: "Old")], requestID: old)
    state.failLoading("Old error", requestID: old)
    #expect(state.loading)
    #expect(state.messages.isEmpty)
    #expect(state.error == nil)
    state.failLoading("Unavailable", requestID: next)
    #expect(!state.loading)
    #expect(state.error == "Unavailable")
    state.reduce(.reload)
    let final = state.loadID!
    #expect(state.error == nil)
    state.finishLoading([.init(text: "Fixture")], requestID: final)
    #expect(state.messages.first?.text == "Fixture")
    #expect(state.connection == .unknown)
}
@Test func dispatchNavigationPreservesChatAndClearsPendingLoadOnNewSession() {
    var state = SessionState()
    state.draft = "Chat draft"
    state.messages = [.init(role: .user, text: "Hello")]
    let messages = state.messages
    state.reduce(.openDispatch)
    let load = state.dispatch.loadID!
    #expect(state.showingDispatch)
    #expect(state.messages == messages)
    #expect(state.draft == "Chat draft")
    state.dispatch.draft = "Task draft"
    state.reduce(.newSession)
    state.dispatch.finishLoading([.init(text: "Late")], requestID: load)
    #expect(!state.showingDispatch)
    #expect(state.dispatch.messages.isEmpty)
    #expect(state.dispatch.draft == "Task draft")
}

@Test func codeFiltersEveryStatusWithoutChangingInjectedSessions() {
    var state = CodeState()
    state.sessions = [
        .init(id: "idle", title: "Idle"), .init(id: "work", title: "Working", status: .working),
        .init(id: "input", title: "Needs input", status: .needsInput),
        .init(id: "review", title: "Review", status: .readyForReview),
        .init(id: "done", title: "Done", status: .completed),
        .init(id: "archived", title: "Archived", status: .working, archived: true)
    ]
    let original = state.sessions
    for (filter, ids): (CodeFilter, [String]) in [
        (.all, ["idle", "work", "input", "review", "done"]), (.working, ["work"]), (.needsInput, ["input"]),
        (.readyForReview, ["review"]), (.completed, ["done"]), (.archived, ["archived"])
    ] {
        state.reduce(.selectFilter(filter))
        #expect(state.visibleSessions.map(\.id) == ids)
        #expect(state.sessions == original)
    }
}
@Test func codeHostIntentsDoNotCreateSessionsOrDevices() {
    var state = CodeState()
    let original = state
    for action: CodeAction in [.addDevice, .openSession("missing"), .openDevice("missing"), .search] {
        state.reduce(action)
    }
    #expect(state == original)
}
@Test func codeNavigationPreservesChatAndExcludesDispatch() {
    var state = SessionState()
    state.draft = "Chat draft"
    state.messages = [.init(role: .user, text: "Hello")]
    let messages = state.messages
    state.reduce(.openDispatch)
    let dispatchLoad = state.dispatch.loadID!
    state.reduce(.openCode)
    #expect(state.showingCode)
    #expect(!state.showingDispatch)
    state.dispatch.finishLoading([.init(text: "Late")], requestID: dispatchLoad)
    #expect(state.dispatch.messages.isEmpty)
    #expect(state.draft == "Chat draft")
    #expect(state.messages == messages)
    state.code.sessions = [.init(id: "one", title: "Keep")]
    state.reduce(.code(.selectFilter(.working)))
    state.reduce(.code(.openRoutines))
    state.reduce(.code(.routines(.newRoutine)))
    state.reduce(.newSession)
    #expect(!state.showingCode)
    #expect(!state.code.showingRoutines)
    #expect(state.code.routines.editor == nil)
    #expect(state.code.sessions.count == 1)
    #expect(state.code.filter == .working)
}
@Test func routineBackPreservesDraftButCancelDiscardsUnsavedForm() {
    var state = RoutineState()
    state.reduce(.edit(.name, "Ignored"))
    #expect(state.draft.name.isEmpty)
    state.reduce(.newRoutine)
    state.reduce(.edit(.description, "Review changes"))
    state.reduce(.manualSetup)
    state.reduce(.edit(.name, "Morning review"))
    state.reduce(.edit(.instructions, "Review sample changes"))
    state.reduce(.addSchedule)
    state.reduce(.backToDescription)
    #expect(state.description == "Review changes")
    #expect(state.draft.name == "Morning review")
    state.reduce(.manualSetup)
    #expect(state.canCreate)
    let before = state
    state.reduce(.create(state.draft))
    state.reduce(.draftRoutine("Review changes"))
    #expect(state == before)
    state.reduce(.cancel)
    #expect(state.editor == nil)
    #expect(state.description.isEmpty)
    #expect(state.draft == RoutineDraft())
    #expect(!state.canCreate)
}
@Test func routineScheduleDefaultsClampsAndRemovalAreLocal() {
    var state = RoutineState()
    state.reduce(.addSchedule)
    #expect(state.draft.schedule == nil)
    state.reduce(.newRoutine)
    state.reduce(.manualSetup)
    state.reduce(.addSchedule)
    #expect(state.draft.schedule?.repeats == .daily)
    #expect(state.draft.schedule?.hour == 1)
    #expect(state.draft.schedule?.minute == 0)
    state.reduce(.setTime(hour: 24, minute: -1))
    #expect(state.draft.schedule?.hour == 1)
    state.reduce(.setTime(hour: 23, minute: 59))
    state.reduce(.setRepeat(.weekdays))
    #expect(state.draft.schedule?.minute == 59)
    state.reduce(.toggleSchedule)
    #expect(!state.scheduleExpanded)
    state.reduce(.removeSchedule)
    state.reduce(.setTime(hour: 2, minute: 0))
    #expect(state.draft.schedule == nil)
    state.reduce(.addSchedule)
    #expect(state.scheduleExpanded)
    #expect(state.draft.schedule?.repeats == .daily)
}

@Test func routineFilterDoesNotChangeUnsavedDraftOrSchedule() {
    var state = RoutineState()
    state.reduce(.newRoutine)
    state.reduce(.manualSetup)
    state.reduce(.edit(.name, "Keep"))
    state.reduce(.addSchedule)
    let draft = state.draft
    state.reduce(.selectFilter(.active))
    #expect(state.filter == .active)
    #expect(state.draft == draft)
    state.reduce(.selectFilter(.inactive))
    state.reduce(.cancel)
    #expect(state.filter == .inactive)
    #expect(state.editor == nil)
}

@Test func codeDraftChoicesRemainSeparateFromOrdinaryChatAndDoNotSubmitWork() {
    var state = SessionState()
    state.reduce(.openCode)
    state.reduce(.code(.newSession))
    state.reduce(.code(.editor(.edit("   "))))
    #expect(!state.code.draft.canSubmit)
    state.reduce(.code(.editor(.edit("Sample task"))))
    state.reduce(.code(.editor(.selectModel(.haiku))))
    state.reduce(.code(.editor(.selectEffort(.ultracode))))
    #expect(state.code.draft.canSubmit)
    #expect(state.model == .opus)
    #expect(state.effort == .high)
    let draft = state.code.draft
    state.reduce(.code(.editor(.submit(draft))))
    #expect(state.code.draft == draft)
    #expect(state.messages.isEmpty)
    state.reduce(.code(.closeNewSession))
    state.reduce(.code(.newSession))
    #expect(state.code.draft.text == "Sample task")
}
@Test func codeRepositoryEnvironmentAndBranchChoicesRejectUnknownIDs() {
    var state = CodeDraftState()
    state.environments = [.init(id: "cloud", name: "Cloud")]
    state.repositories = [.init(id: "one", name: "One"), .init(id: "two", name: "Two")]
    state.branchesByRepository = ["one": [.init(id: "feature", name: "sample_branch")]]
    state.reduce(.selectRepository("one"))
    state.reduce(.selectBranch("feature"))
    #expect(state.repository?.branch == "sample_branch")
    state.reduce(.selectRepository("missing"))
    state.reduce(.selectBranch("missing"))
    #expect(state.repository?.branch == "sample_branch")
    state.reduce(.selectRepository("two"))
    state.reduce(.selectBranch("feature"))
    #expect(state.repository?.branch == "main")
    state.reduce(.selectEnvironment("cloud"))
    state.reduce(.selectEnvironment("missing"))
    #expect(state.environment == "Cloud")
    state.reduce(.context(.selectPermission(.plan)))
    #expect(state.permission == .plan)
}
@Test func environmentCreationIsLocalAndCancellationClearsUnsavedVariables() {
    var state = CodeEnvironmentFormState()
    state.reduce(.editVariables("IGNORED=1"))
    #expect(state.draft.variables.isEmpty)
    state.reduce(.begin)
    #expect(state.draft.network == .trusted)
    state.reduce(.editName("Sample"))
    state.reduce(.editVariables("EXAMPLE=1"))
    state.reduce(.selectNetwork(.none))
    let before = state
    state.reduce(.create(state.draft))
    #expect(state == before)
    state.reduce(.cancel)
    #expect(!state.presented)
    #expect(state.draft == CodeEnvironmentDraft())
}
@Test func leavingCodeEditorCancelsEnvironmentFormAndKeepsUnsentTask() {
    var state = CodeState()
    state.reduce(.newSession)
    state.reduce(.editor(.edit("Keep")))
    state.reduce(.editor(.environment(.begin)))
    state.reduce(.editor(.environment(.editVariables("EXAMPLE=1"))))
    state.reduce(.closeNewSession)
    #expect(!state.draft.environmentForm.presented)
    #expect(state.draft.environmentForm.draft.variables.isEmpty)
    #expect(state.draft.text == "Keep")
}

@Test func connectorPermissionsValidateIDsAndStayWithinSelectedService() {
    var state = CodeConnectorState()
    state.connectors = [
        .init(
            id: "a", name: "A", connected: true,
            tools: [.init(id: "one", name: "One"), .init(id: "two", name: "Two", permission: .blocked)]),
        .init(id: "b", name: "B", connected: true, tools: [.init(id: "one", name: "One")])
    ]
    #expect(state.connectors[0].commonPermission == nil)
    let initial = state
    state.reduce(.permission(connector: "unknown", tool: nil, value: .allowed))
    state.reduce(.permission(connector: "a", tool: "unknown", value: .allowed))
    #expect(state == initial)
    state.reduce(.permission(connector: "a", tool: "one", value: .blocked))
    #expect(state.connectors[0].commonPermission == .blocked)
    #expect(state.connectors[1].commonPermission == .approval)
    state.reduce(.permission(connector: "a", tool: nil, value: .allowed))
    #expect(state.connectors[0].commonPermission == .allowed)
}
@Test func connectorHostIntentsCannotConnectOrMutateDisconnectedTools() {
    var state = CodeConnectorState()
    state.connectors = [.init(id: "sample", name: "Sample", tools: [.init(id: "one", name: "One")])]
    let original = state
    state.reduce(.add)
    state.reduce(.connect("sample"))
    state.reduce(.permission(connector: "sample", tool: nil, value: .allowed))
    #expect(state == original)
    state.reduce(.discovery(true))
    #expect(state.discovery)
    #expect(state.connectors == original.connectors)
}
