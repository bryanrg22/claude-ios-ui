import Foundation

public struct ChatMessage: Identifiable, Equatable, Sendable {
    public enum Role: String, Sendable { case user, assistant }
    public var id: UUID
    public var role: Role
    public var text: String
    public var media: [ClaudeMedia]
    public init(id: UUID = UUID(), role: Role, text: String, media: [ClaudeMedia] = []) {
        self.id = id
        self.role = role
        self.text = text
        self.media = media
    }
}

public enum ClaudeAppearance: String, CaseIterable, Sendable { case system = "System", light = "Light", dark = "Dark" }
public enum ClaudeVoice: String, CaseIterable, Sendable { case clara = "Clara", suave = "Suave" }
public enum ComposerPhase: Equatable, Sendable { case idle, streaming, recording, recordingPaused }
public enum Effort: String, CaseIterable, Sendable {
    case low = "Low", medium = "Medium", high = "High", extra = "Extra", max = "Max"
}
public enum ClaudeModel: String, CaseIterable, Sendable {
    case fable = "Fable 5.1", opus = "Opus 5.5", sonnet = "Sonnet 5.5", haiku = "Haiku 5.5"
    public var detail: String {
        switch self {
        case .fable: "For your toughest challenges"
        case .opus: "For complex work and everyday tasks"
        case .sonnet: "Most efficient for simpler tasks"
        case .haiku: "Fastest for quick answers"
        }
    }
}
public struct FeedbackSubmission: Equatable, Sendable {
    public let positive: Bool
    public let comment: String
    public let issue: String?
    public init(positive: Bool, comment: String = "", issue: String? = nil) {
        self.positive = positive
        self.comment = comment
        self.issue = positive ? nil : issue
    }
}
/// Intents are delivered to the integrating app; the UI has no networking or device access.
public enum ClaudeAction: Equatable, Sendable {
    case send(String), stop, startDictation, stopDictation, cancelDictation, commitDictation
    case newSession, selectModel(ClaudeModel), selectEffort(Effort), setAutomaticApproval(Bool)
    case setDeviceEnabled(Bool), toggleTemporary, startVoice, attach(String), removeAttachment(String)
    case beginEditing(UUID), cancelEditing
    case devices(DeviceAction)
    case openDispatch, dispatch(DispatchAction)
    case openCode, code(CodeAction)
    case openArtifacts, artifacts(ArtifactAction)
    case openProjects, projects(ProjectAction)
    case settings(ClaudeSettingsAction)
    case media(ClaudeMediaAction)
    case markdown(UUID, MarkdownAction)
    case voiceFeedback(Bool)
    case endVoice, toggleVoiceInput, toggleVoiceOutput, selectVoice(ClaudeVoice), selectVoiceLanguage(String)
    case copy(UUID), share(UUID), readAloud(UUID), feedback(UUID, FeedbackSubmission), retry
}

public struct SessionState: Equatable, Sendable {
    public var settings = ClaudeSettingsState()
    public var appearance: ClaudeAppearance = .dark
    public var draft = ""
    public var messages: [ChatMessage] = []
    public var phase: ComposerPhase = .idle
    public private(set) var responseID: UUID?
    public var model: ClaudeModel = .opus
    public var effort: Effort = .high
    public var automaticApproval = false
    public var deviceEnabled = true
    public var devices = DeviceState()
    public var dispatch = DispatchState()
    public var code = CodeState()
    public var artifacts = ArtifactsState()
    public private(set) var showingArtifacts = false
    public var projects = ProjectState()
    public private(set) var showingProjects = false
    public private(set) var showingCode = false
    public private(set) var showingDispatch = false
    public var temporary = false
    public private(set) var voiceActive = false
    public private(set) var voiceInputEnabled = true
    public private(set) var voiceOutputMuted = false
    public var voice: ClaudeVoice = .suave
    public var voiceLanguage = "Spanish (Latin America)"
    public var attachments: [String] = []
    public var media = ClaudeMediaState()
    public var transcript = ""
    /// Host-supplied UI levels only. Nonfinite values become silence, values clamp
    /// to 0...1, and only the newest256 samples are retained. No audio is captured.
    public var dictationLevels: [Double] = [] {
        didSet { dictationLevels = DictationWaveformMetrics.normalized(dictationLevels) }
    }
    public private(set) var editingMessageID: UUID?
    private var draftBeforeEditing = ""
    private var attachmentsBeforeEditing: [String] = []
    private var mediaBeforeEditing: [ClaudeMedia] = []
    public private(set) var draftBeforeDictation = ""
    public init() {}
    public var canSend: Bool {
        phase == .idle
            && (!draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !attachments.isEmpty
                || !media.draft.isEmpty)
    }
    public var visibleMessages: [ChatMessage] {
        guard let editingMessageID, let index = messages.firstIndex(where: { $0.id == editingMessageID }) else {
            return messages
        }
        return Array(messages.prefix(through: index))
    }
    private mutating func clearEditing() {
        editingMessageID = nil
        draftBeforeEditing = ""
        attachmentsBeforeEditing = []
        mediaBeforeEditing = []
    }
    public mutating func reduce(_ action: ClaudeAction) {
        switch action {
        case .send(let text):
            guard phase == .idle,
                !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !attachments.isEmpty
                    || !media.draft.isEmpty
            else { return }
            let attachmentText =
                attachments.isEmpty ? "" : attachments.joined(separator: ", ") + (text.isEmpty ? "" : "\n")
            if let target = editingMessageID {
                guard let index = messages.firstIndex(where: { $0.id == target && $0.role == .user }) else {
                    reduce(.cancelEditing)
                    return
                }
                messages =
                    Array(messages.prefix(index)) + [
                        .init(id: target, role: .user, text: attachmentText + text, media: media.draft)
                    ]
                clearEditing()
            } else {
                messages.append(.init(role: .user, text: attachmentText + text, media: media.draft))
            }
            draft = ""
            attachments = []
            media.draft = []
            media.reduce(.close)
            phase = .streaming
            responseID = UUID()
        case .beginEditing(let target):
            guard phase == .idle, !voiceActive,
                let message = messages.first(where: { $0.id == target && $0.role == .user })
            else { return }
            if editingMessageID == nil {
                draftBeforeEditing = draft
                attachmentsBeforeEditing = attachments
                mediaBeforeEditing = media.draft
            }
            editingMessageID = target
            draft = message.text
            attachments = []
            media.draft = message.media
        case .cancelEditing:
            guard editingMessageID != nil else { return }
            draft = draftBeforeEditing
            attachments = attachmentsBeforeEditing
            media.draft = mediaBeforeEditing
            if phase == .recording || phase == .recordingPaused {
                phase = .idle
                transcript = ""
                dictationLevels = []
            }
            clearEditing()
        case .stop:
            if phase == .streaming {
                phase = .idle
                responseID = nil
            }
        case .startDictation:
            guard phase == .idle, !voiceActive else { return }
            draftBeforeDictation = draft
            transcript = ""
            dictationLevels = []
            phase = .recording
        case .stopDictation:
            guard phase == .recording else { return }
            dictationLevels = []
            if transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                draft = draftBeforeDictation
                transcript = ""
                dictationLevels = []
                phase = .idle
            } else {
                phase = .recordingPaused
            }  // Content-bearing stop remains an unverified host-preview state.
        case .cancelDictation:
            guard phase == .recording || phase == .recordingPaused else { return }
            draft = draftBeforeDictation
            transcript = ""
            dictationLevels = []
            phase = .idle
        case .commitDictation:
            guard phase == .recording || phase == .recordingPaused else { return }
            draft = [draftBeforeDictation, transcript].filter { !$0.isEmpty }.joined(separator: " ")
            transcript = ""
            dictationLevels = []
            phase = .idle
        case .newSession:
            let model = model, effort = effort, automatic = automaticApproval, device = deviceEnabled,
                appearance = appearance, voice = voice, language = voiceLanguage, devices = devices,
                dispatch = dispatch, code = code, projects = projects, artifacts = artifacts,
                recentMedia = media.recent, settings = settings
            self = SessionState()
            self.settings = settings
            self.settings.reduce(.close)
            self.media.recent = recentMedia
            self.artifacts = artifacts
            self.artifacts.reduce(.close)
            self.projects = projects
            self.projects.reduce(.cancel)
            self.code = code
            self.code.reduce(.closeRoutines)
            self.code.reduce(.closeNewSession)
            self.dispatch = dispatch
            self.dispatch.reduce(.close)
            self.devices = devices
            self.appearance = appearance
            self.voice = voice
            self.voiceLanguage = language
            self.model = model
            self.effort = effort
            automaticApproval = automatic
            deviceEnabled = device
        case .settings(let action):
            settings.reduce(action)
            if case .setAppearance(let value) = action { appearance = value }
        case .media(let action): media.reduce(action)
        case .devices(let action): devices.reduce(action)
        case .openArtifacts:
            showingArtifacts = true
            showingProjects = false
            showingCode = false
            showingDispatch = false
            dispatch.reduce(.close)
        case .artifacts(let action): artifacts.reduce(action)
        case .openProjects:
            showingArtifacts = false
            showingProjects = true
            showingCode = false
            showingDispatch = false
            dispatch.reduce(.close)
        case .projects(let action): projects.reduce(action)
        case .openCode:
            showingArtifacts = false
            showingProjects = false
            showingCode = true
            showingDispatch = false
            dispatch.reduce(.close)
        case .code(let action): code.reduce(action)
        case .openDispatch:
            showingArtifacts = false
            showingProjects = false
            showingCode = false
            showingDispatch = true
            dispatch.reduce(.reload)
        case .dispatch(let action): dispatch.reduce(action)
        case .selectModel(let value): model = value
        case .selectEffort(let value): effort = value
        case .setAutomaticApproval(let value): automaticApproval = value
        case .setDeviceEnabled(let value): deviceEnabled = value
        case .toggleTemporary: temporary.toggle()
        case .attach(let name): if !attachments.contains(name) { attachments.append(name) }
        case .removeAttachment(let name): attachments.removeAll { $0 == name }
        case .retry:
            if phase == .idle, editingMessageID == nil, messages.contains(where: { $0.role == .user }) {
                if messages.last?.role == .assistant { messages.removeLast() }
                phase = .streaming
                responseID = UUID()
            }
        case .startVoice: if phase == .idle, editingMessageID == nil { voiceActive = true }
        case .endVoice:
            voiceActive = false
            voiceInputEnabled = true
            voiceOutputMuted = false
        case .toggleVoiceInput: if voiceActive { voiceInputEnabled.toggle() }
        case .toggleVoiceOutput: if voiceActive { voiceOutputMuted.toggle() }
        case .selectVoice(let value): voice = value
        case .selectVoiceLanguage(let value): voiceLanguage = value
        case .copy, .share, .readAloud, .feedback, .voiceFeedback, .markdown: break
        }
    }
    /// Backends and demos both deliver response text here. Late chunks after Stop are ignored.
    public mutating func appendResponse(_ text: String, responseID: UUID) {
        guard phase == .streaming, self.responseID == responseID else { return }
        if messages.last?.role == .assistant {
            messages[messages.count - 1].text += text
        } else {
            messages.append(.init(role: .assistant, text: text))
        }
    }
    public mutating func finishResponse(responseID: UUID) {
        if phase == .streaming, self.responseID == responseID {
            phase = .idle
            self.responseID = nil
        }
    }
}
