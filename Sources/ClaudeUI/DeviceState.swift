import Foundation

public enum DeviceConnectionStatus: Equatable, Sendable { case connected, disconnected, unknown }
public struct ClaudeDevice: Identifiable, Equatable, Sendable {
    public var id: String
    public var name: String
    public var status: DeviceConnectionStatus
    public init(id: String, name: String, status: DeviceConnectionStatus = .unknown) {
        self.id = id
        self.name = name
        self.status = status
    }
}
public enum DeviceAccountTab: String, CaseIterable, Sendable {
    case general = "General", account = "Account", privacy = "Privacy", billing = "Billing", usage = "Usage"
}
public enum DeviceProfileField: Sendable { case fullName, nickname, work, instructions }
public struct DeviceAccountProfile: Equatable, Sendable {
    public var initials: String
    public var fullName: String
    public var nickname: String
    public var work: String
    public var workChoices: [String]
    public var instructions: String
    public var organizationID: String
    public var deletionUnavailableReason: String
    public init(
        initials: String = "", fullName: String = "", nickname: String = "", work: String = "",
        workChoices: [String] = [], instructions: String = "", organizationID: String = "",
        deletionUnavailableReason: String = ""
    ) {
        self.initials = initials
        self.fullName = fullName
        self.nickname = nickname
        self.work = work
        self.workChoices = workChoices
        self.instructions = instructions
        self.organizationID = organizationID
        self.deletionUnavailableReason = deletionUnavailableReason
    }
}
public enum DeviceAccountLoadState: Equatable, Sendable { case idle, loading, loaded, failed(String) }
public enum DeviceAccountOutcome: Equatable, Sendable { case none, success(String), failure(String) }
public enum DeviceAction: Equatable, Sendable {
    case openManage, closeManage, requestTab(DeviceAccountTab), editProfile(DeviceProfileField, String)
    case openAPIDashboard, chooseProfilePhoto, openGuidelines, learnAboutInstructions
    case logOutAllDevices, requestDeleteAccount, copyOrganizationID
}
/// Display state supplied by a host. No device discovery, connection, account request,
/// clipboard access, or logout is performed by this reducer.
public struct DeviceState: Equatable, Sendable {
    public var rows: [ClaudeDevice] = []
    public var profile = DeviceAccountProfile()
    public private(set) var accountLoad: DeviceAccountLoadState = .idle
    public private(set) var accountRequestID: UUID?
    public var outcome: DeviceAccountOutcome = .none
    public init() {}
    public mutating func reduce(_ action: DeviceAction) {
        switch action {
        case .openManage:
            accountRequestID = UUID()
            accountLoad = .loading
            outcome = .none
        case .closeManage:
            accountRequestID = nil
            accountLoad = .idle
            outcome = .none
        case .editProfile(let field, let value):
            guard accountLoad == .loaded else { return }
            switch field {
            case .fullName: profile.fullName = value
            case .nickname: profile.nickname = value
            case .work: profile.work = value
            case .instructions: profile.instructions = value
            }
        default: break
        }
    }
    public mutating func finishAccountLoad(_ profile: DeviceAccountProfile, requestID: UUID) {
        guard accountLoad == .loading, accountRequestID == requestID else { return }
        self.profile = profile
        accountLoad = .loaded
        accountRequestID = nil
    }
    public mutating func failAccountLoad(_ message: String, requestID: UUID) {
        guard accountLoad == .loading, accountRequestID == requestID else { return }
        accountLoad = .failed(message)
        accountRequestID = nil
    }
}
