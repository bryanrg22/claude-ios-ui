#if canImport(UIKit)
    import SwiftUI

    struct ClaudeVoiceSettingsSheet: View {
        @Binding var state: SessionState
        let action: (ClaudeAction) -> Void
        @Environment(\.dismiss) private var dismiss
        @State private var models = false
        var body: some View {
            Group {
                if models {
                    ClaudeModelSheet(state: $state, action: action, voiceContext: true, close: { models = false })
                } else {
                    VStack(spacing: 16) {
                        SheetHeader(title: "Voice settings", close: { dismiss() })
                        GeometryReader { geometry in
                            ScrollView(.horizontal) {
                                HStack(spacing: 20) {
                                    ForEach(ClaudeVoice.allCases, id: \.self) { voice in
                                        Button {
                                            action(.selectVoice(voice))
                                        } label: {
                                            Text(voice.rawValue).font(.system(size: 17)).frame(width: 160, height: 160)
                                                .background {
                                                    RoundedRectangle(cornerRadius: 32).fill(ClaudePalette.background)
                                                        .overlay {
                                                            RoundedRectangle(cornerRadius: 32).fill(
                                                                LinearGradient(
                                                                    colors: [
                                                                        .clear,
                                                                        state.voice == voice
                                                                            ? Color(red: 0.37, green: 0.28, blue: 0.24)
                                                                                .opacity(0.20) : .clear
                                                                    ], startPoint: .center, endPoint: .bottom)
                                                            ).blur(radius: 9).clipped()
                                                        }
                                                }
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 32).stroke(
                                                        LinearGradient(
                                                            colors: [
                                                                .white.opacity(0.10), .white.opacity(0.035),
                                                                state.voice == voice
                                                                    ? Color(red: 0.42, green: 0.32, blue: 0.26).opacity(
                                                                        0.5) : .white.opacity(0.1)
                                                            ], startPoint: .top, endPoint: .bottom), lineWidth: 0.8)
                                                }
                                                .scaleEffect(state.voice == voice ? 1 : 0.75)
                                        }.buttonStyle(.plain).id(voice).accessibilityIdentifier(
                                            "voice.choice.\(voice.rawValue)")
                                    }
                                }.scrollTargetLayout()
                            }.contentMargins(.horizontal, max(0, (geometry.size.width - 160) / 2), for: .scrollContent)
                                .scrollIndicators(.hidden).scrollTargetBehavior(.viewAligned)
                                .defaultScrollAnchor(state.voice == .suave ? .trailing : .leading)
                                .scrollPosition(
                                    id: Binding<ClaudeVoice?>(
                                        get: { state.voice }, set: { if let value = $0 { action(.selectVoice(value)) } }
                                    ), anchor: .center)
                        }.frame(height: 160)
                        HStack(spacing: 8) {
                            ForEach(ClaudeVoice.allCases, id: \.self) { voice in
                                Circle().fill(state.voice == voice ? Color(white: 0.7) : Color(white: 0.22)).frame(
                                    width: 5, height: 5)
                            }
                        }.padding(.top, 4).padding(.bottom, 10)
                        RowGroup {
                            SheetRow(
                                title: "Model", value: state.model.rawValue.components(separatedBy: " ")[0],
                                chevron: true
                            ) { models = true }.accessibilityIdentifier("voice.settings.model")
                        }.padding(.horizontal, 16)
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Text("Language").font(.system(size: 17))
                                Text("Beta").font(.system(size: 11)).padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(.white.opacity(0.055), in: .capsule)
                            }
                            Menu {
                                // Only the selected language was observed; additional options are host supplied.
                                Button(state.voiceLanguage) { action(.selectVoiceLanguage(state.voiceLanguage)) }
                            } label: {
                                HStack(spacing: 10) {
                                    Text(state.voiceLanguage)
                                    Image(systemName: "chevron.up.chevron.down").font(.system(size: 11))
                                }.font(.system(size: 16)).foregroundStyle(ClaudePalette.secondary)
                            }.accessibilityIdentifier("voice.language")
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 16).padding(
                            .vertical, 13
                        ).background(ClaudePalette.panel, in: .rect(cornerRadius: 28)).padding(.horizontal, 16)
                        Spacer(minLength: 0)
                    }
                }
            }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink).presentationDetents([.height(430)]
            ).presentationDragIndicator(.visible).presentationCornerRadius(38)
        }
    }
#endif
