#if canImport(UIKit)
import SwiftUI

struct ClaudePrivacySettingsView: View {
    let state: ClaudePrivacyState
    let action: (ClaudePrivacyAction) -> Void
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Data privacy").font(.system(size: 17))
                    Text("Anthropic believes in transparent data practices.").font(.system(size: 13.3)).foregroundStyle(ClaudePalette.secondary)
                    Text(dataText).font(.system(size: 13.3)).foregroundStyle(ClaudePalette.secondary).lineSpacing(2).fixedSize(horizontal: false, vertical: true).padding(.top, 16)
                }.frame(maxWidth: .infinity, alignment: .leading).padding(16).background(ClaudePalette.panel, in: .rect(cornerRadius: 28))
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Help improve our AI models").font(.system(size: 17))
                        Text(improvementText).font(.system(size: 13.3)).foregroundStyle(ClaudePalette.secondary).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    Toggle("Help improve our AI models", isOn: Binding(get: { state.allowsModelImprovement }, set: { action(.requestModelImprovement($0)) })).labelsHidden().tint(ClaudeSettingsColors.switchTint).frame(width: 63).accessibilityIdentifier("settings.privacy.modelImprovement")
                }.padding(16).background(ClaudePalette.panel, in: .rect(cornerRadius: 28))
            }.padding(.horizontal, 16).padding(.top, 26).padding(.bottom, 24)
        }.tint(ClaudePalette.secondary).accessibilityIdentifier("settings.privacy.scroll")
            .environment(\.openURL, OpenURLAction { url in
                guard url.scheme == "claude-ui-privacy", let host = url.host, let link = ClaudePrivacyLink.allCases.first(where: { $0.rawValue.lowercased() == host.lowercased() }) else { return .discarded }
                action(.openLink(link, state.links[link])); return .handled
            })
    }
    private func linked(_ link: ClaudePrivacyLink) -> AttributedString {
        var text = AttributedString(link.title)
        text.link = URL(string: "claude-ui-privacy://" + link.rawValue)
        text.underlineStyle = .single
        return text
    }
    private var dataText: AttributedString {
        AttributedString("Keeping your data safe is a priority. Learn how your information is protected when using Anthropic products, and visit our ") + linked(.privacyCenter) + AttributedString(" and ") + linked(.privacyPolicy) + AttributedString(" for more details.")
    }
    private var improvementText: AttributedString {
        AttributedString("Allow the use of your chats and coding sessions to train and improve Anthropic AI models. ") + linked(.learnMore)
    }
}
#endif
