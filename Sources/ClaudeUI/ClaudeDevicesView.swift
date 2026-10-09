#if canImport(UIKit)
import SwiftUI

public struct ClaudeDevicesView: View {
    @Binding private var state: DeviceState
    private let action: (DeviceAction) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var managing = false
    public init(state: Binding<DeviceState>, action: @escaping (DeviceAction) -> Void) { _state = state; self.action = action }
    public var body: some View {
        VStack(spacing: 20) {
            SheetHeader(title: "Devices", controlDiameter: 44, close: { dismiss() })
            RowGroup {
                ForEach(state.rows) { device in
                    HStack(spacing: 12) {
                        Image(systemName: "laptopcomputer").font(.system(size: 20, weight: .light)).foregroundStyle(ClaudePalette.secondary)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(device.name).font(.system(size: 17))
                            HStack(spacing: 8) {
                                Circle().fill(device.status == .connected ? .green : ClaudePalette.secondary).frame(width: 7, height: 7)
                                Text(device.status == .connected ? "Connected" : device.status == .disconnected ? "Disconnected" : "Unknown").font(.system(size: 13)).foregroundStyle(ClaudePalette.secondary)
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }.padding(.horizontal, 18).padding(.vertical, 16).accessibilityElement(children: .combine).accessibilityIdentifier("devices.row.\(device.id)")
                    RowDivider()
                }
                SheetRow(title: "Manage devices", symbol: "gearshape", chevron: true) { action(.openManage); managing = true }.accessibilityIdentifier("devices.manage")
            }.padding(.horizontal, 16)
            Spacer(minLength: 0)
        }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink).presentationDetents([.height(415)]).presentationDragIndicator(.visible).presentationCornerRadius(38)
            .sheet(isPresented: $managing, onDismiss: { action(.closeManage) }) { ClaudeManageDevicesView(state: $state, action: action) }
    }
}

public struct ClaudeManageDevicesView: View {
    @Binding private var state: DeviceState
    private let action: (DeviceAction) -> Void
    @Environment(\.dismiss) private var dismiss
    public init(state: Binding<DeviceState>, action: @escaping (DeviceAction) -> Void) { _state = state; self.action = action }
    public var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Manage devices", controlDiameter: 44, close: { action(.closeManage); dismiss() }).padding(.bottom, 5)
            Divider()
            switch state.accountLoad {
            case .idle, .loading: Spacer(); ProgressView().accessibilityLabel("Loading account"); Spacer()
            case .failed(let message):
                Spacer(); Text(message).multilineTextAlignment(.center).padding(24)
                Button("Try again") { action(.openManage) }.buttonStyle(.bordered); Spacer()
            case .loaded: accountContent
            }
        }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink).tint(ClaudePalette.ink).presentationDetents([.large]).presentationDragIndicator(.hidden)
    }
    private var accountContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView(.horizontal) {
                    HStack(spacing: 5) { ForEach(DeviceAccountTab.allCases, id: \.self) { tab in
                        Button { action(.requestTab(tab)) } label: { Text(tab.rawValue).font(.system(size: 15)).padding(.horizontal, 12).padding(.vertical, 11).background(tab == .account ? ClaudePalette.adaptive(light: 0.88, dark: 0.22) : .clear, in: .rect(cornerRadius: 9)) }.buttonStyle(.plain).accessibilityAddTraits(tab == .account ? [.isSelected] : [])
                    } }
                }.scrollIndicators(.hidden).padding(.horizontal, 0).padding(.top, 6)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Platform").font(.system(size: 13)).foregroundStyle(ClaudePalette.secondary).padding(.top, 33)
                    Button { action(.openAPIDashboard) } label: { HStack(spacing: 14) { Text("API keys"); Image(systemName: "arrow.up.right.square").font(.system(size: 13)) }.font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary) }.padding(.top, 16)
                    Text("Profile").font(.system(size: 16, weight: .semibold)).padding(.top, 30).padding(.bottom, 22)
                    photoRow
                    accountDivider
                    profileField(label: "Full name", field: .fullName, value: state.profile.fullName, identifier: "devices.profile.name").padding(.vertical, 12)
                    accountDivider
                    profileField(label: "What should\nClaude call\nyou?", field: .nickname, value: state.profile.nickname, identifier: "devices.profile.nickname").padding(.vertical, 12)
                    accountDivider
                    workRow.padding(.vertical, 20)
                    accountDivider
                    instructions.padding(.top, 14)
                    Text("Account").font(.system(size: 16, weight: .semibold)).padding(.top, 58).padding(.bottom, 18)
                    HStack { Text("Log out of all devices"); Spacer(); Button("Log out") { action(.logOutAllDevices) }.buttonStyle(AccountButtonStyle()).accessibilityIdentifier("devices.logout") }.font(.system(size: 15)).padding(.vertical, 14)
                    accountDivider
                    HStack(spacing: 16) {
                        Text(state.profile.deletionUnavailableReason).font(.system(size: 15)).fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                        Button("Delete account") { action(.requestDeleteAccount) }.buttonStyle(AccountButtonStyle()).disabled(true).accessibilityIdentifier("devices.delete")
                    }.padding(.vertical, 14)
                    accountDivider
                    organizationRow.padding(.vertical, 14)
                    if case .success(let text) = state.outcome { Text(text).font(.footnote).foregroundStyle(.green) }
                    if case .failure(let text) = state.outcome { Text(text).font(.footnote).foregroundStyle(.red) }
                }.padding(.horizontal, 12).padding(.bottom, 20)
            }
        }.scrollDismissesKeyboard(.interactively).accessibilityIdentifier("devices.account.scroll")
    }
    private var accountDivider: some View { Rectangle().fill(ClaudePalette.ink.opacity(0.06)).frame(height: 1) }
    private var photoRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 7) { Text("Profile photo").font(.system(size: 15)); Text("PNG, JPEG, or WebP, up to 10MB.").font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary) }
            Spacer()
            Button { action(.chooseProfilePhoto) } label: { Text(state.profile.initials).font(.system(size: 15)).frame(width: 40, height: 40).background(ClaudePalette.adaptive(light: 0.90, dark: 0.17), in: .circle) }.buttonStyle(.plain).accessibilityLabel("Profile photo")
        }.padding(.bottom, 15)
    }
    private func profileField(label: String, field: DeviceProfileField, value: String, identifier: String) -> some View {
        HStack(spacing: 12) {
            Text(label).font(.system(size: 15)).lineSpacing(3).frame(width: 120, alignment: .leading)
            TextField(label.replacingOccurrences(of: "\n", with: " "), text: Binding(get: { value }, set: { action(.editProfile(field, $0)) })).font(.system(size: 16)).padding(.horizontal, 11).padding(.vertical, 6).background(ClaudePalette.panel, in: .rect(cornerRadius: 8)).overlay { RoundedRectangle(cornerRadius: 8).stroke(ClaudePalette.ink.opacity(0.1), lineWidth: 1) }.accessibilityIdentifier(identifier)
        }
    }
    private var workRow: some View {
        HStack {
            Text("What best describes your work?").font(.system(size: 15)); Spacer(minLength: 10)
            Menu { ForEach(state.profile.workChoices, id: \.self) { choice in Button(choice) { action(.editProfile(.work, choice)) } } } label: { HStack(spacing: 8) { Text(state.profile.work); Image(systemName: "chevron.down").font(.system(size: 11)) }.font(.system(size: 15)) }
        }
    }
    private var instructions: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Instructions for Claude").font(.system(size: 15))
            Text("Claude will keep these in mind for this and any of your associated accounts across chats within [Anthropic’s guidelines](claude-ui://guidelines). [Learn more](claude-ui://instructions)").font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary).tint(ClaudePalette.secondary).lineSpacing(4).environment(\.openURL, OpenURLAction { url in action(url.host == "guidelines" ? .openGuidelines : .learnAboutInstructions); return .handled })
            ZStack(alignment: .topLeading) {
                if state.profile.instructions.isEmpty { Text("e.g. keep explanations brief and to the point").foregroundStyle(ClaudePalette.secondary).padding(11).allowsHitTesting(false) }
                TextEditor(text: Binding(get: { state.profile.instructions }, set: { action(.editProfile(.instructions, $0)) })).scrollContentBackground(.hidden).padding(6).accessibilityIdentifier("devices.profile.instructions")
            }.font(.system(size: 15)).frame(height: 94).background(ClaudePalette.panel, in: .rect(cornerRadius: 8)).overlay { RoundedRectangle(cornerRadius: 8).stroke(ClaudePalette.ink.opacity(0.1), lineWidth: 1) }.padding(.top, 8)
        }
    }
    private var organizationRow: some View {
        HStack(spacing: 10) {
            Text("Organization\nID").font(.system(size: 15)).frame(width: 98, alignment: .leading)
            HStack(spacing: 7) {
                Text(state.profile.organizationID).font(.system(size: 12, design: .monospaced)).lineLimit(1)
                Button { action(.copyOrganizationID) } label: { Image(systemName: "square.on.square").font(.system(size: 13)) }.buttonStyle(.plain).accessibilityLabel("Copy organization ID").accessibilityIdentifier("devices.organization.copy")
            }.foregroundStyle(ClaudePalette.secondary).padding(5).background(ClaudePalette.panel, in: .rect(cornerRadius: 4))
        }
    }
}
private struct AccountButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled
    func makeBody(configuration: Configuration) -> some View { configuration.label.foregroundStyle(enabled ? ClaudePalette.ink : ClaudePalette.secondary).font(.system(size: 14)).padding(.horizontal, 10).padding(.vertical, 5).background(ClaudePalette.adaptive(light: 0.88, dark: configuration.isPressed ? 0.25 : 0.16), in: .rect(cornerRadius: 7)) }
}
#endif
