#if canImport(UIKit)
import SwiftUI

struct ClaudeBillingSettingsView: View {
    let state: ClaudeBillingState
    let action: (ClaudeBillingAction) -> Void
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                RowGroup {
                    HStack { Text("Account plan"); Spacer(); Text(state.planLabel).foregroundStyle(ClaudePalette.secondary).accessibilityIdentifier("settings.billing.plan") }.font(.system(size: 17)).padding(.horizontal, 16).frame(height: 50)
                }
                RowGroup {
                    row("Manage subscription", symbol: "dollarsign.circle", id: "manage") { action(.requestManage) }
                    Divider().padding(.leading, 56).padding(.trailing, 16)
                    row("Restore purchases", symbol: "arrow.clockwise", id: "restore") { action(.requestRestore) }
                }
            }.padding(.horizontal, 16).padding(.top, 26)
        }.alert("Manage subscription", isPresented: Binding(get: { state.showsWebsiteNotice }, set: { if !$0 { action(.dismissNotice) } })) {
            Button("Manage on claude.ai") { action(.requestWebsiteManagement(state.managementURL)) }
            Button("OK", role: .cancel) { action(.dismissNotice) }
        } message: { Text("You subscribed on claude.ai. Change or cancel your plan there.") }
    }
    private func row(_ title: String, symbol: String, id: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) { Image(systemName: symbol).font(.system(size: 20)).foregroundStyle(ClaudePalette.secondary).frame(width: 24); Text(title).font(.system(size: 17)); Spacer() }.padding(.horizontal, 16).frame(height: 50).contentShape(Rectangle())
        }.buttonStyle(.plain).accessibilityIdentifier("settings.billing." + id)
    }
}
#endif
