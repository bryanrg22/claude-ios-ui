#if canImport(UIKit)
    import SwiftUI

    struct ClaudeCapabilitiesView: View {
        let state: ClaudeCapabilitiesState
        let action: (ClaudeCapabilityAction) -> Void
        private let tools: [ClaudeCapability] = [.artifacts, .inlineVisualizations, .codeExecution, .switchFlaggedModel]
        private let memories: [ClaudeCapability] = [.searchChats, .generateMemory, .sensitiveMemory]
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    RowGroup {
                        ForEach(Array(tools.enumerated()), id: \.element) { index, value in
                            if index > 0 { Divider().padding(.leading, 48).padding(.trailing, 16) }
                            row(value)
                        }
                    }
                    Text("Memory").font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary).padding(
                        .horizontal, 16
                    ).padding(.top, 26).padding(.bottom, 10)
                    RowGroup {
                        ForEach(memories, id: \.self) { value in
                            row(value)
                            Divider().padding(.horizontal, 16)
                        }
                        Button {
                            action(.openMemoryFiles)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Memory files").font(.system(size: 17))
                                    Text("View and manage what Claude remembers.").font(.system(size: 13.3))
                                        .foregroundStyle(ClaudePalette.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 16)).foregroundStyle(
                                    ClaudePalette.secondary)
                            }.padding(16).contentShape(Rectangle())
                        }.buttonStyle(.plain).accessibilityIdentifier("settings.capabilities.memoryFiles")
                    }
                }.padding(.horizontal, 16).padding(.top, 26).padding(.bottom, 24)
            }.accessibilityIdentifier("settings.capabilities.scroll").environment(
                \.openURL,
                OpenURLAction { url in
                    guard
                        let raw = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: {
                            $0.name == "key"
                        })?.value, let key = ClaudeCapability(rawValue: raw)
                    else { return .discarded }
                    action(.openHelp(key, state.helpURLs[key]))
                    return .handled
                })
        }
        private func row(_ capability: ClaudeCapability) -> some View {
            let value = state[capability]
            return HStack(alignment: capability.symbol == nil ? .center : .top, spacing: 8) {
                if let symbol = capability.symbol {
                    Image(systemName: symbol).font(.system(size: 20)).foregroundStyle(ClaudePalette.secondary).frame(
                        width: 24
                    ).padding(.top, 2)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        Text(capability.title).font(.system(size: 17))
                        if capability == .inlineVisualizations {
                            Text("Beta").font(.system(size: 11, weight: .semibold)).padding(.horizontal, 8).padding(
                                .vertical, 4
                            ).background(ClaudePalette.ink.opacity(0.04), in: .capsule)
                        }
                    }
                    if let dependency = value.dependencyLabel {
                        Text(dependency).font(.system(size: 13.3)).foregroundStyle(ClaudePalette.secondary)
                    } else if !capability.subtitle.isEmpty {
                        Text(subtitle(capability)).font(.system(size: 13.3)).foregroundStyle(ClaudePalette.secondary)
                            .tint(ClaudePalette.secondary).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                Toggle(
                    capability.title,
                    isOn: Binding(get: { value.isEnabled }, set: { action(.requestEnabled(capability, $0)) })
                ).labelsHidden().tint(ClaudeSettingsColors.switchTint).frame(width: 63).disabled(!value.isEditable)
                    .accessibilityIdentifier("settings.capability." + capability.rawValue)
            }.padding(16).opacity(value.isEditable ? 1 : 0.5)
        }
        private func subtitle(_ capability: ClaudeCapability) -> AttributedString {
            var text = AttributedString(capability.subtitle)
            if capability.hasHelp {
                text += AttributedString(" ")
                var link = AttributedString("Learn more.")
                link.link = URL(string: "claude-capability://help?key=" + capability.rawValue)
                link.underlineStyle = .single
                text += link
            }
            return text
        }
    }
#endif
