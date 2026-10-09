#if canImport(UIKit)
    import SwiftUI

    enum ClaudeSettingsColors {
        // Repeated solid switch pixels sampled from the captured October 8 dark reference.
        static let switchTint = Color(red: 101 / 255, green: 151 / 255, blue: 224 / 255)
    }
    struct ClaudeNotificationSettingsView: View {
        let preferences: ClaudeNotificationPreferences
        let action: (ClaudeSettingsAction) -> Void
        var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Array(ClaudeNotificationPreference.groups.enumerated()), id: \.offset) { _, group in
                        RowGroup {
                            ForEach(Array(group.enumerated()), id: \.element) { index, preference in
                                if index > 0 { Divider().padding(.horizontal, 16) }
                                HStack(spacing: 8) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(preference.title).font(.system(size: 17))
                                        Text(preference.subtitle).font(.system(size: 13.3)).foregroundStyle(
                                            ClaudePalette.secondary
                                        ).fixedSize(horizontal: false, vertical: true)
                                    }.frame(maxWidth: .infinity, alignment: .leading)
                                    Toggle(
                                        preference.title,
                                        isOn: Binding(
                                            get: { preferences[preference] },
                                            set: { action(.setNotification(preference, $0)) })
                                    ).labelsHidden().tint(ClaudeSettingsColors.switchTint).frame(width: 63)
                                        .accessibilityIdentifier("settings.notification." + preference.rawValue)
                                }.padding(.horizontal, 16).padding(.vertical, 16)
                            }
                        }
                    }
                }.padding(.horizontal, 16).padding(.top, 26).padding(.bottom, 24)
            }.accessibilityIdentifier("settings.notifications.scroll")
        }
    }
#endif
