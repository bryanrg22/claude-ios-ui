#if canImport(UIKit)
import SwiftUI

struct ClaudeCodeSettingsView: View {
    let state: ClaudeCodePreferences
    let action: (ClaudeCodePreferenceAction) -> Void
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                section("Appearance")
                RowGroup {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Transcript text size").font(.system(size: 17))
                        Slider(value: Binding(get: { state.transcriptSizePosition }, set: { action(.transcriptSizePosition($0)) }), in: 0...1) { Text("Transcript text size") } minimumValueLabel: { Text("A").font(.system(size: 14)) } maximumValueLabel: { Text("A").font(.system(size: 18)) }
                            .tint(.blue).foregroundStyle(ClaudePalette.secondary).accessibilityIdentifier("settings.code.size")
                    }.padding(.horizontal, 16).padding(.vertical, 16)
                    Divider().padding(.horizontal, 16)
                    HStack {
                        Text("Transcript font"); Spacer()
                        Menu { Picker("Transcript font", selection: Binding(get: { state.transcriptFont }, set: { action(.transcriptFont($0)) })) { ForEach(ClaudeTranscriptFontChoice.allCases, id: \.self) { Text($0.rawValue).tag($0) } } } label: { choice(state.transcriptFont.rawValue) }.accessibilityIdentifier("settings.code.transcriptFont")
                    }.font(.system(size: 17)).padding(.horizontal, 16).frame(height: 50)
                    Divider().padding(.horizontal, 16)
                    HStack {
                        Text("Code font"); Spacer()
                        Menu { Picker("Code font", selection: Binding(get: { state.codeFont }, set: { action(.codeFont($0)) })) { ForEach(ClaudeCodeFontChoice.allCases, id: \.self) { Text($0.rawValue).tag($0) } } } label: { choice(state.codeFont.rawValue) }.accessibilityIdentifier("settings.code.codeFont")
                    }.font(.system(size: 17)).padding(.horizontal, 16).frame(height: 50)
                }
                section("Code appearance").padding(.top, 16)
                RowGroup { Toggle("Wrap long lines", isOn: Binding(get: { state.wrapLongLines }, set: { action(.wrapLongLines($0)) })).font(.system(size: 17)).tint(ClaudeSettingsColors.switchTint).padding(.horizontal, 16).frame(height: 50).accessibilityIdentifier("settings.code.wrap") }
            }.padding(.horizontal, 16).padding(.top, 36).padding(.bottom, 24)
        }.accessibilityIdentifier("settings.code.scroll")
    }
    private func section(_ title: String) -> some View { Text(title).font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary).padding(.horizontal, 16) }
    private func choice(_ title: String) -> some View { HStack(spacing: 5) { Text(title); Image(systemName: "chevron.up.chevron.down").font(.system(size: 12, weight: .semibold)) }.foregroundStyle(ClaudeSettingsColors.switchTint) }
}
#endif
