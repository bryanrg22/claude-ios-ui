import Foundation

public struct ClaudeAccountSummary: Equatable, Sendable {
    public var email: String
    public var accountLabel: String
    public var planLabel: String
    public init(email: String = "", accountLabel: String = "Personal", planLabel: String = "") {
        self.email = email
        self.accountLabel = accountLabel
        self.planLabel = planLabel
    }
}
public struct ClaudeProfile: Equatable, Sendable {
    public var initials: String
    public var fullName: String
    public var nickname: String
    public var instructions: String
    public init(initials: String = "", fullName: String = "", nickname: String = "", instructions: String = "") {
        self.initials = initials
        self.fullName = fullName
        self.nickname = nickname
        self.instructions = instructions
    }
}
public enum ClaudeProfileField: Sendable { case fullName, nickname, instructions }
public enum ClaudeSettingsDestination: String, Equatable, Sendable, CaseIterable {
    case about = "About", account = "Account", addAccount = "Add account", gift = "Give the gift of Claude"
    case profile = "Profile", billing = "Billing", usage = "Usage", notifications = "Notifications", timeAndFocus =
        "Time & focus", privacy = "Privacy", sharedLinks = "Shared links"
    case memoryFiles = "Memory files"
    case capabilities = "Capabilities", code = "Claude Code", connectors = "Connectors", permissions = "Permissions",
        voice = "Voice"
}
public struct ClaudeProfileSubmission: Equatable, Sendable {
    public let id: UUID
    public let profile: ClaudeProfile
    public init(id: UUID = UUID(), profile: ClaudeProfile) {
        self.id = id
        self.profile = profile
    }
}
public enum ClaudeSettingsInfoLink: String, Equatable, Sendable, CaseIterable {
    case usagePolicy = "Usage Policy", consumerTerms = "Consumer Terms", privacyPolicy = "Privacy Policy", licenses =
        "Licenses", support = "Help & Support"
}
@nonexhaustive public enum ClaudeSettingsAction: Equatable, Sendable {
    case infoLink(ClaudeSettingsInfoLink)
    case open(ClaudeSettingsDestination), back, close
    case editProfile(ClaudeProfileField, String), submitProfile, editPhoto
    case chooseAvatar, requestPhotoLibrary, requestCamera
    case openInstructions, editInstructions(String), cancelInstructions, applyInstructions
    case billing(ClaudeBillingAction), sharedLinks(ClaudeSharedLinksAction)
    case connector(ClaudeSettingsConnectorAction)
    case capability(ClaudeCapabilityAction), memory(ClaudeMemoryFilesAction)
    case codePreference(ClaudeCodePreferenceAction)
    case usage(ClaudeUsageAction)
    case privacy(ClaudePrivacyAction)
    case timeFocus(ClaudeTimeFocusAction)
    case setNotification(ClaudeNotificationPreference, Bool)
    case setHaptics(Bool), setAppearance(ClaudeAppearance)
    case requestDeleteAccount, requestLogOut, openGuidelines
}
/// Reversible presentation state only. Saving a profile requires explicit host acknowledgement.
public struct ClaudeSettingsState: Equatable, Sendable {
    public var account = ClaudeAccountSummary()
    public var profile = ClaudeProfile()
    public var billing = ClaudeBillingState()
    public var sharedLinks = ClaudeSharedLinksState()
    public var connectors = ClaudeSettingsConnectorState()
    public var capabilities = ClaudeCapabilitiesState()
    public var memoryFiles = ClaudeMemoryFilesState()
    public var codePreferences = ClaudeCodePreferences()
    public var usage = ClaudeUsageState()
    public var privacy = ClaudePrivacyState()
    public var timeFocus = ClaudeTimeFocusState()
    public var notifications = ClaudeNotificationPreferences()
    public var hapticsEnabled = true
    public var versionLabel = ""
    public private(set) var destination: ClaudeSettingsDestination?
    public private(set) var profileDraft: ClaudeProfile?
    public private(set) var pendingProfile: ClaudeProfileSubmission?
    public private(set) var instructionsDraft: String?
    public init() {}
    public mutating func reduce(_ action: ClaudeSettingsAction) {
        switch action {
        case .open(let destination):
            sharedLinks.reduce(.back)
            billing.reduce(.dismissNotice)
            memoryFiles.reduce(.close)
            connectors.close()
            self.destination = destination
            pendingProfile = nil
            instructionsDraft = nil
            profileDraft = destination == .profile ? profile : nil
        case .back, .close:
            sharedLinks.reduce(.back)
            billing.reduce(.dismissNotice)
            memoryFiles.reduce(.close)
            connectors.close()
            destination = nil
            profileDraft = nil
            pendingProfile = nil
            instructionsDraft = nil
        case .editProfile(let field, let value):
            guard destination == .profile, profileDraft != nil else { return }
            pendingProfile = nil
            switch field {
            case .fullName: profileDraft?.fullName = value
            case .nickname: profileDraft?.nickname = value
            case .instructions: profileDraft?.instructions = value
            }
        case .submitProfile:
            guard destination == .profile, let profileDraft, pendingProfile == nil, instructionsDraft == nil else {
                return
            }
            pendingProfile = .init(profile: profileDraft)
        case .openInstructions:
            guard destination == .profile, let profileDraft else { return }
            instructionsDraft = profileDraft.instructions
            pendingProfile = nil
        case .editInstructions(let value):
            guard instructionsDraft != nil else { return }
            instructionsDraft = value
        case .cancelInstructions: instructionsDraft = nil
        case .applyInstructions:
            guard let instructionsDraft, destination == .profile else { return }
            profileDraft?.instructions = instructionsDraft
            self.instructionsDraft = nil
            pendingProfile = nil
        case .billing(let action):
            guard destination == .billing else { return }
            billing.reduce(action)
        case .sharedLinks(let action):
            guard destination == .sharedLinks else { return }
            sharedLinks.reduce(action)
        case .connector(let action):
            guard destination == .connectors else { return }
            if case .back = action, connectors.connector == nil {
                destination = nil
                connectors.close()
            } else {
                connectors.reduce(action)
            }
        case .capability(let action):
            if case .openMemoryFiles = action, destination == .capabilities { destination = .memoryFiles }
        case .memory(let action):
            guard destination == .memoryFiles else { return }
            if case .back = action, memoryFiles.selected == nil {
                memoryFiles.reduce(.close)
                destination = .capabilities
            } else {
                memoryFiles.reduce(action)
            }
        case .codePreference(let action): codePreferences.reduce(action)
        case .timeFocus(let action): timeFocus.reduce(action)
        case .setNotification(let preference, let enabled): notifications[preference] = enabled
        case .setHaptics(let enabled): hapticsEnabled = enabled
        case .usage, .privacy, .infoLink, .setAppearance, .editPhoto, .chooseAvatar, .requestPhotoLibrary,
            .requestCamera, .requestDeleteAccount, .requestLogOut, .openGuidelines:
            break
        }
    }
    /// A failed save leaves the user's draft available for correction or retry.
    /// The host owns any error presentation; no uncaptured error UI is invented here.
    public mutating func rejectProfile(requestID: UUID) {
        guard pendingProfile?.id == requestID else { return }
        pendingProfile = nil
    }
    /// Ignore late success from a canceled, replaced, or subsequently edited draft.
    public mutating func acknowledgeProfile(requestID: UUID, profile: ClaudeProfile? = nil) {
        guard let submission = pendingProfile, submission.id == requestID, destination == .profile else { return }
        self.profile = profile ?? submission.profile
        reduce(.back)
    }
}
