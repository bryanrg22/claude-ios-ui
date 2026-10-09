#if canImport(UIKit)
    import SwiftUI

    struct ClaudeUsageSettingsView: View {
        let state: ClaudeUsageState
        let action: (ClaudeUsageAction) -> Void
        private let progressColor = Color(red: 0.19, green: 0.47, blue: 0.81)
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let current = state.currentSession { RowGroup { meter(current) } }
                    if !state.weekly.isEmpty {
                        section("Weekly limits")
                        RowGroup {
                            ForEach(Array(state.weekly.enumerated()), id: \.element.id) { index, item in
                                if index > 0 { Divider().padding(.horizontal, 16) }
                                meter(item)
                            }
                        }
                    }
                    section("Credits")
                    RowGroup {
                        HStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Usage credits").font(.system(size: 17))
                                Text(creditsDescription).font(.system(size: 13.3)).foregroundStyle(
                                    ClaudePalette.secondary
                                ).lineSpacing(2).fixedSize(horizontal: false, vertical: true).tint(
                                    ClaudePalette.secondary)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                            Toggle(
                                "Usage credits",
                                isOn: Binding(
                                    get: { state.creditsEnabled }, set: { action(.requestCreditsEnabled($0)) })
                            ).labelsHidden().tint(ClaudeSettingsColors.switchTint).frame(width: 63)
                                .accessibilityIdentifier("settings.usage.creditsEnabled")
                        }.padding(.horizontal, 16).padding(.vertical, 16)
                        Divider().padding(.horizontal, 16)
                        HStack {
                            Text("Current balance").font(.system(size: 16))
                            Spacer()
                            Text(state.balanceLabel).font(.system(size: 17)).foregroundStyle(ClaudePalette.secondary)
                                .accessibilityIdentifier("settings.usage.balance")
                        }.padding(.horizontal, 16).frame(height: 50)
                        if !state.credits.isEmpty { Divider().padding(.horizontal, 16) }
                        ForEach(Array(state.credits.enumerated()), id: \.element.id) { index, credit in
                            if index > 0 { Divider().padding(.leading, 48).padding(.trailing, 16) }
                            creditRow(credit)
                        }
                    }
                    Text(creditsFooter).font(.system(size: 13.3)).foregroundStyle(ClaudePalette.secondary).lineSpacing(
                        2
                    ).tint(ClaudeSettingsColors.switchTint).padding(.horizontal, 16).padding(.top, 8)
                    RowGroup {
                        Button {
                            action(.requestPurchase)
                        } label: {
                            Label("Buy usage credits", systemImage: "creditcard").font(.system(size: 17)).frame(
                                maxWidth: .infinity, alignment: .leading
                            ).padding(.horizontal, 16).frame(height: 52).contentShape(Rectangle())
                        }.buttonStyle(.plain).foregroundStyle(progressColor).accessibilityIdentifier(
                            "settings.usage.buy")
                    }.padding(.top, 24)
                }.padding(.horizontal, 16).padding(.top, 26).padding(.bottom, 24)
            }.accessibilityIdentifier("settings.usage.scroll").environment(
                \.openURL,
                OpenURLAction { url in
                    guard url.scheme == "claude-ui-usage", url.host == "credits" else { return .discarded }
                    action(.openLink(.creditsHelp, state.creditsHelpURL))
                    return .handled
                })
        }
        private func section(_ title: String) -> some View {
            Text(title).font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary).padding(.horizontal, 16)
                .padding(.top, 26).padding(.bottom, 10)
        }
        private func meter(_ item: ClaudeUsageMeter) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.title).font(.system(size: 17))
                    Spacer()
                    Text(item.usageLabel).font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary)
                }
                ProgressView(value: item.fractionUsed ?? 0).progressViewStyle(UsageBarStyle(color: progressColor))
                    .frame(height: 8).accessibilityLabel(item.title).accessibilityValue(
                        item.fractionUsed == nil ? "Unavailable" : item.usageLabel
                    ).accessibilityIdentifier("settings.usage.meter." + item.id)
                if !item.resetLabel.isEmpty {
                    Text(item.resetLabel).font(.system(size: 13.3)).foregroundStyle(ClaudePalette.secondary)
                }
            }.padding(.horizontal, 16).padding(.vertical, 20)
        }
        private func creditRow(_ item: ClaudeUsageCredit) -> some View {
            HStack(spacing: 8) {
                ZStack {
                    Circle().stroke(progressColor.opacity(0.3), lineWidth: 3)
                    if let fraction = item.fractionUsed, fraction > 0 {
                        Circle().trim(from: 0, to: fraction).stroke(
                            progressColor, style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        ).rotationEffect(.degrees(-90))
                    }
                }.frame(width: 24, height: 24).accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title).font(.system(size: 15))
                    if !item.subtitle.isEmpty {
                        Text(item.subtitle).font(.system(size: 12.5)).foregroundStyle(ClaudePalette.secondary)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                if !item.badge.isEmpty {
                    Text(item.badge).font(.system(size: 11, weight: .semibold)).padding(.horizontal, 9).padding(
                        .vertical, 4
                    ).background(ClaudePalette.ink.opacity(0.035), in: .capsule)
                }
            }.padding(.horizontal, 16).padding(.vertical, 20).accessibilityElement(children: .combine)
                .accessibilityIdentifier("settings.usage.credit." + item.id)
        }
        private var creditsDescription: AttributedString {
            attributed("Turn on usage credits to keep using Claude if you hit a plan limit. ")
        }
        private var creditsFooter: AttributedString {
            attributed("Usage credits cover you when you hit your plan limits.\n")
        }
        private func attributed(_ prefix: String) -> AttributedString {
            var link = AttributedString("Learn more")
            link.link = URL(string: "claude-ui-usage://credits")
            link.underlineStyle = .single
            return AttributedString(prefix) + link
        }
    }
    private struct UsageBarStyle: ProgressViewStyle {
        let color: Color
        @Environment(\.colorScheme) private var colorScheme
        func makeBody(configuration: Configuration) -> some View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(
                        colorScheme == .dark
                            ? Color(red: 10 / 255, green: 30 / 255, blue: 64 / 255) : color.opacity(0.24))
                    Capsule().fill(color).frame(
                        width: geometry.size.width * min(1, max(0, configuration.fractionCompleted ?? 0)))
                }
            }
        }
    }
#endif
