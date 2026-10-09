import Foundation

public enum ClaudeTranscriptFontChoice: String, CaseIterable, Codable, Sendable { case anthropicSans = "Anthropic Sans", system = "System" }
public enum ClaudeCodeFontChoice: String, CaseIterable, Codable, Sendable { case sfMono = "SF Mono", jetBrainsMono = "JetBrains Mono" }
public enum ClaudeCodePreferenceAction: Equatable, Sendable {
    case transcriptSizePosition(Double), transcriptFont(ClaudeTranscriptFontChoice), codeFont(ClaudeCodeFontChoice), wrapLongLines(Bool)
}
/// Font names are host integration choices, not bundled font files. The size position is
/// normalized UI state; the real app's point-size mapping was not measured.
public struct ClaudeCodePreferences: Equatable, Codable, Sendable {
    public private(set) var transcriptSizePosition: Double
    public private(set) var transcriptFont: ClaudeTranscriptFontChoice
    public private(set) var codeFont: ClaudeCodeFontChoice
    public private(set) var wrapLongLines: Bool
    public init(transcriptSizePosition: Double = 0.5, transcriptFont: ClaudeTranscriptFontChoice = .system, codeFont: ClaudeCodeFontChoice = .sfMono, wrapLongLines: Bool = false) {
        self.transcriptSizePosition = transcriptSizePosition.isFinite ? min(1, max(0, transcriptSizePosition)) : 0.5
        self.transcriptFont = transcriptFont; self.codeFont = codeFont; self.wrapLongLines = wrapLongLines
    }
    private enum CodingKeys: String, CodingKey { case transcriptSizePosition, transcriptFont, codeFont, wrapLongLines }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(transcriptSizePosition: try values.decode(Double.self, forKey: .transcriptSizePosition), transcriptFont: try values.decode(ClaudeTranscriptFontChoice.self, forKey: .transcriptFont), codeFont: try values.decode(ClaudeCodeFontChoice.self, forKey: .codeFont), wrapLongLines: try values.decode(Bool.self, forKey: .wrapLongLines))
    }
    public mutating func reduce(_ action: ClaudeCodePreferenceAction) {
        switch action {
        case .transcriptSizePosition(let value): guard value.isFinite else { return }; transcriptSizePosition = min(1, max(0, value))
        case .transcriptFont(let value): transcriptFont = value
        case .codeFont(let value): codeFont = value
        case .wrapLongLines(let value): wrapLongLines = value
        }
    }
}
