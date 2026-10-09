import Foundation
import Testing
@testable import ClaudeUI

private func configuredSettings() -> ClaudeSettingsState {
    var state = ClaudeSettingsState()
    state.profile = .init(initials: "JL", fullName: "Jordan Lee", nickname: "Jordan", instructions: "Keep it concise")
    return state
}
@Test func profileBackAndCloseDiscardAllDraftFields() {
    for exit in [ClaudeSettingsAction.back, .close] {
        var state = configuredSettings()
        let original = state.profile
        state.reduce(.open(.profile))
        state.reduce(.editProfile(.fullName, "Updated"))
        state.reduce(.editProfile(.nickname, "J"))
        state.reduce(.editProfile(.instructions, "New instructions"))
        #expect(state.profile == original)
        state.reduce(exit)
        #expect(state.profileDraft == nil)
        #expect(state.profile == original)
        state.reduce(.open(.profile))
        #expect(state.profileDraft == original)
    }
}
@Test func profileSaveWaitsForAcknowledgementAndRejectsDuplicateSubmit() {
    var state = configuredSettings()
    state.reduce(.open(.profile))
    state.reduce(.editProfile(.nickname, "Jay"))
    state.reduce(.submitProfile)
    let submission = state.pendingProfile!
    #expect(state.profile.nickname == "Jordan")
    state.reduce(.submitProfile)
    #expect(state.pendingProfile?.id == submission.id)
    state.acknowledgeProfile(requestID: UUID())
    #expect(state.profile.nickname == "Jordan")
    state.acknowledgeProfile(requestID: submission.id)
    #expect(state.profile.nickname == "Jay")
    #expect(state.destination == nil)
}
@Test func canceledOrReplacedProfileRequestCannotChangeCommittedProfile() {
    for replacement in [ClaudeSettingsAction.back, .close, .open(.billing), .editProfile(.nickname, "Newer")] {
        var state = configuredSettings()
        let original = state.profile
        state.reduce(.open(.profile))
        state.reduce(.editProfile(.nickname, "Old request"))
        state.reduce(.submitProfile)
        let token = state.pendingProfile!.id
        state.reduce(replacement)
        state.acknowledgeProfile(requestID: token)
        #expect(state.profile == original)
        #expect(state.pendingProfile == nil)
    }
}
@Test func profileHostNormalizationAndEmptyFieldsArePreserved() {
    var state = configuredSettings()
    state.reduce(.editProfile(.fullName, "Ignored"))
    #expect(state.profileDraft == nil)
    state.reduce(.submitProfile)
    #expect(state.pendingProfile == nil)
    state.reduce(.open(.profile))
    state.reduce(.editProfile(.nickname, ""))
    state.reduce(.submitProfile)
    var normalized = state.pendingProfile!.profile
    normalized.fullName = "Host normalized name"
    state.acknowledgeProfile(requestID: state.pendingProfile!.id, profile: normalized)
    #expect(state.profile.nickname.isEmpty)
    #expect(state.profile.fullName == "Host normalized name")
}
@Test func settingsDestructiveAndPhotoIntentsDoNotMutateAccount() {
    var state = configuredSettings()
    state.reduce(.open(.profile))
    let original = state
    for action in [
        ClaudeSettingsAction.editPhoto, .chooseAvatar, .requestPhotoLibrary, .requestCamera, .requestDeleteAccount,
        .requestLogOut, .openGuidelines
    ] {
        state.reduce(action)
        #expect(state == original)
    }
}
@Test func newSessionKeepsSettingsButInvalidatesProfileDraftAndPendingSave() {
    var state = SessionState()
    state.settings = configuredSettings()
    state.settings.account.email = "jordan@example.com"
    state.reduce(.settings(.setHaptics(false)))
    state.reduce(.settings(.setAppearance(.light)))
    state.reduce(.settings(.open(.profile)))
    state.reduce(.settings(.editProfile(.nickname, "Unsaved")))
    state.reduce(.settings(.submitProfile))
    let token = state.settings.pendingProfile!.id
    state.reduce(.newSession)
    state.settings.acknowledgeProfile(requestID: token)
    #expect(state.settings.profile.nickname == "Jordan")
    #expect(state.settings.profileDraft == nil)
    #expect(state.settings.destination == nil)
    #expect(state.settings.account.email == "jordan@example.com")
    #expect(!state.settings.hapticsEnabled)
    #expect(state.appearance == .light)
}

@Test func nestedInstructionsCancelPreservesOtherProfileEdits() {
    var state = configuredSettings()
    state.reduce(.open(.profile))
    state.reduce(.editProfile(.nickname, "Jay"))
    state.reduce(.openInstructions)
    state.reduce(.editInstructions("Abandoned"))
    state.reduce(.cancelInstructions)
    #expect(state.profileDraft?.instructions == "Keep it concise")
    #expect(state.profileDraft?.nickname == "Jay")
    state.reduce(.openInstructions)
    #expect(state.instructionsDraft == "Keep it concise")
    state.reduce(.editInstructions("New instructions"))
    state.reduce(.applyInstructions)
    #expect(state.profileDraft?.instructions == "New instructions")
    #expect(state.profile.instructions == "Keep it concise")
    #expect(state.instructionsDraft == nil)
    state.reduce(.back)
    #expect(state.profile.instructions == "Keep it concise")
}
@Test func nestedInstructionsCannotRestoreDraftAfterDismissal() {
    var state = configuredSettings()
    state.reduce(.openInstructions)
    #expect(state.instructionsDraft == nil)
    state.reduce(.open(.profile))
    state.reduce(.openInstructions)
    state.reduce(.editInstructions("Stale"))
    state.reduce(.close)
    state.reduce(.applyInstructions)
    #expect(state.profileDraft == nil)
    #expect(state.instructionsDraft == nil)
    #expect(state.profile.instructions == "Keep it concise")
}

@Test func openingNestedInstructionsInvalidatesPendingProfileSave() {
    var state = configuredSettings()
    state.reduce(.open(.profile))
    state.reduce(.submitProfile)
    let token = state.pendingProfile!.id
    state.reduce(.openInstructions)
    state.acknowledgeProfile(requestID: token)
    #expect(state.destination == .profile)
    #expect(state.instructionsDraft != nil)
    state.reduce(.submitProfile)
    #expect(state.pendingProfile == nil)
}

@Test func failedProfileSaveKeepsDraftAndPermitsFreshRetry() {
    var state = configuredSettings()
    state.reduce(.open(.profile))
    state.reduce(.editProfile(.nickname, "Jay"))
    state.reduce(.submitProfile)
    let original = state.pendingProfile!.id
    state.rejectProfile(requestID: UUID())
    #expect(state.pendingProfile?.id == original)
    state.rejectProfile(requestID: original)
    #expect(state.profileDraft?.nickname == "Jay")
    #expect(state.profile.nickname == "Jordan")
    state.reduce(.submitProfile)
    #expect(state.pendingProfile != nil)
    #expect(state.pendingProfile?.id != original)
    state.acknowledgeProfile(requestID: original)
    #expect(state.profile.nickname == "Jordan")
}

@Test func notificationPreferencesToggleIndependentlyAndIdempotently() {
    var state = ClaudeSettingsState()
    for preference in ClaudeNotificationPreference.allCases {
        state.reduce(.setNotification(preference, true))
        state.reduce(.setNotification(preference, true))
        #expect(state.notifications.enabled == [preference])
        state.reduce(.setNotification(preference, false))
        #expect(state.notifications.enabled.isEmpty)
    }
    #expect(ClaudeNotificationPreference.groups.flatMap { $0 } == ClaudeNotificationPreference.allCases)
}
@Test func notificationPreferencesRoundTripForHostPersistence() throws {
    let preferences = ClaudeNotificationPreferences(enabled: [.replies, .dispatchMessages, .codePermissions])
    let restored = try JSONDecoder().decode(ClaudeNotificationPreferences.self, from: JSONEncoder().encode(preferences))
    #expect(restored == preferences)
}
@Test func notificationPreferencesSurviveNavigationAndNewConversation() {
    var state = SessionState()
    state.reduce(.settings(.open(.notifications)))
    state.reduce(.settings(.setNotification(.replies, true)))
    state.reduce(.settings(.back))
    state.reduce(.settings(.open(.profile)))
    state.reduce(.settings(.close))
    state.reduce(.newSession)
    #expect(state.settings.notifications.enabled == [.replies])
    #expect(state.settings.destination == nil)
}

@Test func timeFocusOnlyAcceptsCapturedHourAndMinuteChoices() {
    var state = ClaudeTimeFocusState()
    for hours in 1...12 {
        state.reduce(.selectHours(hours))
        #expect(state.hours == hours)
    }
    for minutes in [15, 30, 45] {
        state.reduce(.selectMinutes(minutes))
        #expect(state.minutes == minutes)
    }
    for hours in [-1, 0, 13, Int.max] {
        state.reduce(.selectHours(hours))
        #expect(state.hours == 12)
    }
    for minutes in [-1, 0, 1, 60, Int.max] {
        state.reduce(.selectMinutes(minutes))
        #expect(state.minutes == 45)
    }
    state.reduce(.selectHours(nil))
    state.reduce(.selectMinutes(nil))
    #expect(state == .init())
}
@Test func timeFocusHostPersistenceSanitizesOutOfRangeValues() throws {
    let original = ClaudeTimeFocusState(hours: 2, minutes: 30)
    #expect(try JSONDecoder().decode(ClaudeTimeFocusState.self, from: JSONEncoder().encode(original)) == original)
    #expect(
        try JSONDecoder().decode(ClaudeTimeFocusState.self, from: Data("{\"hours\":24,\"minutes\":60}".utf8)) == .init()
    )
}
@Test func quietDayIntentsDoNotInventUncapturedSelectedState() {
    var state = ClaudeTimeFocusState(hours: 1, minutes: 15)
    let original = state
    for day in ClaudeWeekday.allCases {
        state.reduce(.quietDayTapped(day))
        #expect(state == original)
    }
    var session = SessionState()
    session.reduce(.settings(.timeFocus(.selectHours(1))))
    session.reduce(.settings(.timeFocus(.selectMinutes(45))))
    session.reduce(.newSession)
    #expect(session.settings.timeFocus == .init(hours: 1, minutes: 45))
}

@Test func privacyConsentRequestsNeverMutateHostConsentOrNavigate() {
    var state = ClaudeSettingsState()
    #expect(!state.privacy.allowsModelImprovement)
    state.privacy = .init(
        allowsModelImprovement: true, links: [.privacyCenter: URL(string: "https://example.com/privacy")!])
    state.reduce(.open(.privacy))
    let original = state
    state.reduce(.privacy(.requestModelImprovement(false)))
    #expect(state == original)
    state.reduce(.privacy(.requestModelImprovement(true)))
    #expect(state == original)
    for link in ClaudePrivacyLink.allCases {
        state.reduce(.privacy(.openLink(link, state.privacy.links[link])))
        #expect(state == original)
    }
}
@Test func hostPrivacyTruthAndLinksSurviveNewSession() {
    var state = SessionState()
    let url = URL(string: "https://example.com/model-preference")!
    state.settings.privacy = .init(allowsModelImprovement: true, links: [.learnMore: url])
    state.reduce(.newSession)
    #expect(state.settings.privacy.allowsModelImprovement)
    #expect(state.settings.privacy.links[.learnMore] == url)
}

@Test func usageUnknownValuesAreDistinctFromZeroAndFiniteValuesAreClamped() {
    for invalid in [Double.nan, .infinity, -.infinity] {
        let meter = ClaudeUsageMeter(id: "m", title: "Meter", usedPercentage: invalid)
        #expect(meter.fractionUsed == nil)
        #expect(meter.usageLabel == "—")
        #expect(ClaudeUsageCredit(id: "c", title: "Credit", usedPercentage: invalid).fractionUsed == nil)
    }
    #expect(ClaudeUsageMeter(id: "m", title: "Meter").fractionUsed == nil)
    #expect(ClaudeUsageMeter(id: "m", title: "Meter", usedPercentage: 0).usageLabel == "0% used")
    for (input, output) in [(-4.0, 0.0), (25.5, 0.255), (999.0, 1.0)] {
        #expect(ClaudeUsageMeter(id: "m", title: "Meter", usedPercentage: input).fractionUsed == output)
        #expect(ClaudeUsageCredit(id: "c", title: "Credit", usedPercentage: input).fractionUsed == output)
    }
}
@Test func usageHostRequestsDoNotChangeBalancesConsentOrNavigation() {
    var state = ClaudeSettingsState()
    state.usage = .init(creditsEnabled: true, balanceLabel: "18 credits")
    state.reduce(.open(.usage))
    let original = state
    for action in [
        ClaudeUsageAction.refresh, .requestPurchase, .requestCreditsEnabled(false), .requestCreditsEnabled(true),
        .openLink(.usageHelp, nil), .openLink(.creditsHelp, URL(string: "https://example.com/help"))
    ] {
        state.reduce(.usage(action))
        #expect(state == original)
    }
}
@Test func usageHostDataIsPreservedAcrossNewSessionWithoutInventedDefaults() {
    var session = SessionState()
    #expect(session.settings.usage.currentSession == nil)
    #expect(session.settings.usage.weekly.isEmpty)
    #expect(session.settings.usage.balanceLabel == "—")
    #expect(!session.settings.usage.creditsEnabled)
    let value = ClaudeUsageState(
        weekly: [.init(id: "custom", title: "Host model", usedPercentage: 50)], creditsEnabled: true,
        balanceLabel: "Host amount", credits: [.init(id: "c", title: "Host transaction")],
        usageHelpURL: URL(string: "https://example.com/help"))
    session.settings.usage = value
    session.reduce(.settings(.open(.usage)))
    session.reduce(.newSession)
    #expect(session.settings.usage == value)
    #expect(session.settings.destination == nil)
}

@Test func billingWebsiteNoticeDoesNotChangeSubscriptionAndHostActionsStayRequests() {
    var state = ClaudeBillingState(
        planLabel: "Host plan", origin: .website, managementURL: URL(string: "https://example.com/billing"))
    let original = state
    state.reduce(.requestManage)
    #expect(state.showsWebsiteNotice)
    state.reduce(.requestRestore)
    #expect(state.showsWebsiteNotice)
    #expect(state.planLabel == original.planLabel)
    state.reduce(.dismissNotice)
    #expect(state == original)
    state.reduce(.requestManage)
    state.reduce(.requestWebsiteManagement(state.managementURL))
    #expect(state == original)
}
@Test func billingOnlyCapturedWebsiteOriginOpensLocalNotice() {
    for origin in [ClaudeSubscriptionOrigin.unknown, .appStore, .other("Host")] {
        var state = ClaudeBillingState(origin: origin)
        let original = state
        state.reduce(.requestManage)
        #expect(state == original)
    }
    var state = ClaudeSettingsState()
    state.billing = .init(planLabel: "Host plan", origin: .website)
    state.reduce(.billing(.requestManage))
    #expect(!state.billing.showsWebsiteNotice)
    state.reduce(.open(.billing))
    state.reduce(.billing(.requestManage))
    #expect(state.billing.showsWebsiteNotice)
    state.reduce(.back)
    #expect(!state.billing.showsWebsiteNotice)
    #expect(state.billing.planLabel == "Host plan")
}
@Test func sharedLinksRejectUnknownIDsAndPreserveOriginalSnapshotContent() {
    let snapshot = ClaudeSharedSnapshot(
        id: "s", title: "Title", sharedLabel: "Shared recently", byline: "Shared by host",
        messages: [.init(role: .user, text: "Question"), .init(role: .assistant, text: "Answer")])
    var state = ClaudeSharedLinksState(groups: [.init(id: "g", title: "Month", snapshots: [snapshot])])
    state.reduce(.open("missing"))
    #expect(state.selected == nil)
    state.reduce(.open("s"))
    #expect(state.selected == snapshot)
    state.reduce(.open("missing"))
    #expect(state.selected == snapshot)
    state.reduce(.back)
    #expect(state.selected == nil)
    #expect(state.groups.first?.snapshots == [snapshot])
}
@Test func settingsCloseAndNewSessionClearSharedSelectionAndBillingNoticeButPreserveHostData() {
    var session = SessionState()
    session.settings.billing = .init(planLabel: "Host", origin: .website)
    session.settings.sharedLinks = .init(groups: [
        .init(
            id: "g", title: "Month", snapshots: [.init(id: "s", title: "Title", sharedLabel: "Recent", byline: "Host")])
    ])
    session.reduce(.settings(.sharedLinks(.open("s"))))
    #expect(session.settings.sharedLinks.selected == nil)
    session.reduce(.settings(.open(.sharedLinks)))
    session.reduce(.settings(.sharedLinks(.open("s"))))
    #expect(session.settings.sharedLinks.selected != nil)
    session.reduce(.newSession)
    #expect(session.settings.sharedLinks.selected == nil)
    #expect(session.settings.sharedLinks.groups.count == 1)
    session.reduce(.settings(.open(.billing)))
    session.reduce(.settings(.billing(.requestManage)))
    session.reduce(.newSession)
    #expect(!session.settings.billing.showsWebsiteNotice)
    #expect(session.settings.billing.planLabel == "Host")
}
@Test func sharedSelectionCannotExposeRemovedHostSnapshot() {
    var state = ClaudeSharedLinksState(groups: [
        .init(
            id: "g", title: "Month", snapshots: [.init(id: "s", title: "Title", sharedLabel: "Recent", byline: "Host")])
    ])
    state.reduce(.open("s"))
    state.groups = []
    #expect(state.selected == nil)
}

@Test func codePreferenceSizeClampsFinitePositionsAndIgnoresNonfiniteChanges() {
    var state = ClaudeCodePreferences()
    #expect(state.transcriptSizePosition == 0.5)
    for (input, output) in [(-1.0, 0.0), (0.33, 0.33), (4.0, 1.0)] {
        state.reduce(.transcriptSizePosition(input))
        #expect(state.transcriptSizePosition == output)
    }
    for value in [Double.nan, .infinity, -.infinity] {
        state.reduce(.transcriptSizePosition(value))
        #expect(state.transcriptSizePosition == 1)
        #expect(ClaudeCodePreferences(transcriptSizePosition: value).transcriptSizePosition == 0.5)
    }
}
@Test func codePreferencesPersistIndependentlyWithoutBundledFonts() throws {
    var state = ClaudeCodePreferences()
    state.reduce(.transcriptFont(.anthropicSans))
    state.reduce(.codeFont(.jetBrainsMono))
    state.reduce(.wrapLongLines(true))
    #expect(state.transcriptSizePosition == 0.5)
    #expect(try JSONDecoder().decode(ClaudeCodePreferences.self, from: JSONEncoder().encode(state)) == state)
    var session = SessionState()
    session.settings.codePreferences = state
    session.reduce(.settings(.open(.code)))
    session.reduce(.newSession)
    #expect(session.settings.codePreferences == state)
    session.reduce(.settings(.codePreference(.wrapLongLines(false))))
    #expect(!session.settings.codePreferences.wrapLongLines)
    #expect(session.settings.codePreferences.codeFont == .jetBrainsMono)
}
@Test func codePreferenceDecoderSanitizesHostPosition() throws {
    let json = Data(
        "{\"transcriptSizePosition\":30,\"transcriptFont\":\"System\",\"codeFont\":\"SF Mono\",\"wrapLongLines\":false}"
            .utf8)
    #expect(try JSONDecoder().decode(ClaudeCodePreferences.self, from: json).transcriptSizePosition == 1)
}

@Test func capabilitiesRequestsNeverChangeHostConsentOrDependencies() {
    var state = ClaudeSettingsState()
    state.capabilities = .init(values: [
        .artifacts: .init(isEnabled: true, isEditable: false, dependencyLabel: "Required by code execution"),
        .generateMemory: .init(isEnabled: true)
    ])
    let original = state.capabilities
    for key in ClaudeCapability.allCases {
        state.reduce(.capability(.requestEnabled(key, true)))
        state.reduce(.capability(.requestEnabled(key, false)))
        state.reduce(.capability(.openHelp(key, nil)))
        #expect(state.capabilities == original)
    }
    #expect(!ClaudeCapabilitiesState()[.sensitiveMemory].isEnabled)
    state.reduce(.capability(.openMemoryFiles))
    #expect(state.destination == nil)
    state.reduce(.open(.capabilities))
    state.reduce(.capability(.openMemoryFiles))
    #expect(state.destination == .memoryFiles)
    state.reduce(.memory(.back))
    #expect(state.destination == .capabilities)
}
private func memoryFixture() -> ClaudeMemoryFilesState {
    .init(groups: [
        .init(
            id: "g", title: "Topics",
            files: [
                .init(id: "a", title: "Garden", markdown: "Original A"),
                .init(id: "b", title: "Reading", markdown: "Original B")
            ])
    ])
}
@Test func memoryNavigationPreservesIndependentDraftsAndSubmitIsHostOnly() {
    var state = memoryFixture()
    state.reduce(.editDraft("List draft"))
    state.reduce(.open("a"))
    #expect(state.draft.isEmpty)
    state.reduce(.editDraft("File draft"))
    let original = state
    state.reduce(.submitInstruction(fileID: "a", text: state.draft))
    #expect(state == original)
    state.reduce(.open("b"))
    #expect(state.draft.isEmpty)
    state.reduce(.back)
    #expect(state.draft == "List draft")
    state.reduce(.open("a"))
    #expect(state.draft == "File draft")
    state.reduce(.close)
    state.reduce(.open("a"))
    #expect(state.draft.isEmpty)
}
@Test func memoryDeleteCancelNeverMutatesFilesAndConfirmationRequiresVisibleFile() {
    var state = memoryFixture()
    let files = state.groups
    state.reduce(.confirmDelete)
    #expect(state.pendingDeletion == nil)
    state.reduce(.open("missing"))
    #expect(state.selected == nil)
    state.reduce(.open("a"))
    state.reduce(.askDelete)
    #expect(state.deletionCandidate?.id == "a")
    state.reduce(.cancelDelete)
    state.reduce(.confirmDelete)
    #expect(state.groups == files)
    #expect(state.pendingDeletion == nil)
    state.reduce(.askDelete)
    state.reduce(.open("b"))
    state.reduce(.confirmDelete)
    #expect(state.pendingDeletion == nil)
}
@Test func memoryDeletionNeedsMatchingHostAcknowledgement() {
    var state = memoryFixture()
    state.reduce(.open("a"))
    state.reduce(.askDelete)
    state.reduce(.confirmDelete)
    let request = state.pendingDeletion!
    #expect(state.groups[0].files.count == 2)
    state.reduce(.confirmDelete)
    #expect(state.pendingDeletion == request)
    state.acknowledgeDeletion(requestID: UUID())
    #expect(state.groups[0].files.count == 2)
    state.acknowledgeDeletion(requestID: request.id)
    #expect(state.groups[0].files.map(\.id) == ["b"])
    #expect(state.selected == nil)
    #expect(state.pendingDeletion == nil)
}
@Test func memoryLateDeletionAfterNavigationOrNewSessionIsIgnored() {
    var state = memoryFixture()
    state.reduce(.open("a"))
    state.reduce(.askDelete)
    state.reduce(.confirmDelete)
    let token = state.pendingDeletion!.id
    state.reduce(.back)
    state.acknowledgeDeletion(requestID: token)
    #expect(state.groups[0].files.count == 2)
    var session = SessionState()
    session.settings.memoryFiles = memoryFixture()
    session.reduce(.settings(.open(.memoryFiles)))
    session.reduce(.settings(.memory(.open("a"))))
    session.reduce(.settings(.memory(.askDelete)))
    session.reduce(.settings(.memory(.confirmDelete)))
    let nextToken = session.settings.memoryFiles.pendingDeletion!.id
    session.reduce(.newSession)
    session.settings.memoryFiles.acknowledgeDeletion(requestID: nextToken)
    #expect(session.settings.memoryFiles.groups[0].files.count == 2)
}
@Test func memoryDeletionFailureAllowsRetryAndRemovedHostFileCannotBeDeletedAgain() {
    var state = memoryFixture()
    state.reduce(.open("a"))
    state.reduce(.askDelete)
    state.reduce(.confirmDelete)
    let first = state.pendingDeletion!.id
    state.rejectDeletion(requestID: UUID())
    #expect(state.pendingDeletion != nil)
    state.rejectDeletion(requestID: first)
    state.reduce(.askDelete)
    state.reduce(.confirmDelete)
    #expect(state.pendingDeletion?.id != first)
    state.groups = []
    state.acknowledgeDeletion(requestID: state.pendingDeletion!.id)
    #expect(state.selected == nil)
}

@Test func hostMemoryDraftReplacementInvalidatesNativeEditorWithoutChangingFiles() {
    var state = memoryFixture()
    state.reduce(.open("a"))
    state.reduce(.editDraft("Typing"))
    let files = state.groups
    let revision = state.editorRevision
    state.reduce(.replaceDraft(""))
    #expect(state.draft.isEmpty)
    #expect(state.editorRevision != revision)
    #expect(state.groups == files)
    state.reduce(.replaceDraft("Host text"))
    #expect(state.draft == "Host text")
    state.reduce(.back)
    #expect(state.draft.isEmpty)
    state.reduce(.open("a"))
    #expect(state.draft == "Host text")
}
private func settingsConnectorFixture() -> ClaudeSettingsConnectorState {
    .init(
        discovery: true,
        connectors: [
            .init(
                id: "connected", name: "Host connector", connected: true,
                tools: [
                    .init(id: "a", name: "A", permission: .approval), .init(id: "b", name: "B", permission: .blocked)
                ]), .init(id: "offline", name: "Available")
        ], toolDescriptions: ["connected": ["a": "Host description"]])
}
@Test func settingsConnectorRequestsNeverMutateHostConnectionOrPolicies() {
    var state = settingsConnectorFixture()
    let original = state
    for action in [
        ClaudeSettingsConnectorAction.requestDiscovery(false), .requestConnect("offline"), .requestCatalog,
        .requestAllTools("connected"), .requestPermission(connector: "connected", tool: "a", permission: .allowed)
    ] {
        state.reduce(action)
        #expect(state == original)
    }
}
@Test func settingsConnectorNavigationValidatesHostRecordsAndBackHierarchy() {
    var state = settingsConnectorFixture()
    state.reduce(.openConnector("offline"))
    #expect(state.connector == nil)
    state.reduce(.openConnector("missing"))
    #expect(state.connector == nil)
    state.reduce(.openConnector("connected"))
    state.reduce(.openTool("missing"))
    #expect(state.tool == nil)
    state.reduce(.openTool("a"))
    #expect(state.toolDescription == "Host description")
    state.reduce(.back)
    #expect(state.tool == nil)
    #expect(state.connector != nil)
    state.reduce(.back)
    #expect(state.connector == nil)
}
@Test func settingsConnectorCloseAndHostRemovalCannotExposeStalePermission() {
    var session = SessionState()
    session.settings.connectors = settingsConnectorFixture()
    session.reduce(.settings(.open(.connectors)))
    session.reduce(.settings(.connector(.openConnector("connected"))))
    session.reduce(.settings(.connector(.openTool("a"))))
    session.reduce(.newSession)
    #expect(session.settings.connectors.tool == nil)
    #expect(session.settings.connectors.discovery)
    var state = settingsConnectorFixture()
    state.reduce(.openConnector("connected"))
    state.reduce(.openTool("a"))
    state.connectors = []
    #expect(state.tool == nil)
    #expect(state.toolDescription.isEmpty)
}

@Test func connectorCatalogFiltersIntersectAndSortStably() {
    var state = ClaudeConnectorCatalogState(
        items: [
            .init(id: "b", name: "Beta", detail: "Health notes", categories: ["Health"], ranks: [.popular: 2]),
            .init(id: "a", name: "Alpha", categories: ["Work"], ranks: [.popular: 1]),
            .init(id: "c", name: "Gamma", detail: "Health study", categories: ["Health"], ranks: [.popular: 2])
        ], categories: ["Health", "Work"])
    state.reduce(.sort(.popular))
    #expect(state.visibleItems.map(\.id) == ["a", "b", "c"])
    state.reduce(.category("Health"))
    state.reduce(.search("  STUDY "))
    #expect(state.visibleItems.map(\.id) == ["c"])
    state.reduce(.category("Unknown"))
    #expect(state.category == "Health")
    state.reduce(.search(""))
    state.reduce(.category(nil))
    state.reduce(.sort(.alphabetical))
    #expect(state.visibleItems.map(\.id) == ["a", "b", "c"])
    state.reduce(.search("No match"))
    #expect(state.visibleItems.isEmpty)
}
@Test func customConnectorValidationRejectsNonHTTPSCredentialsAndBlankDrafts() {
    var state = ClaudeConnectorCatalogState()
    state.reduce(.editName("  "))
    state.reduce(.editURL("https://example.com/mcp"))
    #expect(!state.draft.canSubmit)
    state.reduce(.editName("Example"))
    #expect(state.draft.canSubmit)
    for value in [
        "", "http://example.com", "https://", "https://user:pass@example.com", "https://example.com/#fragment",
        "https://ex ample.com", "file:///tmp/a"
    ] {
        state.reduce(.editURL(value))
        #expect(!state.draft.canSubmit)
    }
    state.reduce(.editURL(" https://example.com/mcp?version=1 "))
    #expect(state.draft.canSubmit)
    let original = state
    state.reduce(.requestCustom(name: "Example", url: state.draft.validatedURL!))
    #expect(state == original)
    state.reduce(.dismiss)
    #expect(state.draft == ClaudeCustomConnectorDraft())
}
@Test func catalogConnectionRequestsAndBulkPoliciesAreHostOwned() {
    var state = settingsConnectorFixture()
    state.catalog = .init(items: [.init(id: "a", name: "A")])
    state.reduce(.openCatalog)
    let rows = state.catalog.items
    state.reduce(.catalog(.requestConnect("a")))
    #expect(state.catalog.items == rows)
    state.reduce(.catalog(.dismiss))
    #expect(state.presentation == nil)
    state.reduce(.openConnector("connected"))
    state.reduce(.openAllTools)
    #expect(state.showingAllTools)
    #expect(state.connector?.commonPermission == nil)
    let connectors = state.connectors
    state.reduce(.requestAllPermissions(connector: "connected", permission: .allowed))
    #expect(state.connectors == connectors)
    state.reduce(.back)
    #expect(!state.showingAllTools)
    #expect(state.connector != nil)
    state.reduce(.back)
    state.reduce(.openAllTools)
    #expect(!state.showingAllTools)
}
@Test func catalogCloseAndNewSessionClearDraftWithoutChangingHostData() {
    var session = SessionState()
    session.settings.connectors = settingsConnectorFixture()
    session.reduce(.settings(.open(.connectors)))
    session.reduce(.settings(.connector(.openCustom)))
    session.reduce(.settings(.connector(.catalog(.editName("Draft")))))
    #expect(session.settings.connectors.catalog.draft.name == "Draft")
    let rows = session.settings.connectors.connectors
    session.reduce(.newSession)
    #expect(session.settings.connectors.presentation == nil)
    #expect(session.settings.connectors.catalog.draft.name.isEmpty)
    #expect(session.settings.connectors.connectors == rows)
    session.reduce(.settings(.connector(.catalog(.editName("Stale")))))
    #expect(session.settings.connectors.catalog.draft.name.isEmpty)
}
@Test func bulkPolicyNavigationCannotOutliveHostConnector() {
    var state = settingsConnectorFixture()
    state.reduce(.openConnector("connected"))
    state.reduce(.openAllTools)
    #expect(state.showingAllTools)
    state.connectors = []
    #expect(!state.showingAllTools)
    #expect(state.connector == nil)
    state.connectors = settingsConnectorFixture().connectors
    state.reduce(.openConnector("connected"))
    #expect(!state.showingAllTools)
    state.reduce(.openAllTools)
    state.reduce(.openTool("a"))
    #expect(!state.showingAllTools)
    #expect(state.tool?.id == "a")
}
