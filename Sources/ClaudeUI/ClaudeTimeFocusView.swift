#if canImport(UIKit)
import SwiftUI

/// Captured time-and-focus body. A host may supply the still-unobserved quiet-day detail.
public struct ClaudeTimeFocusView: View {
    public var state: ClaudeTimeFocusState
    private let quietHoursContent: (() -> AnyView)?
    private let action: (ClaudeTimeFocusAction) -> Void
    @State private var picker: ClaudeBreakUnit?
    @Environment(\.colorScheme) private var colorScheme
    public init(state: ClaudeTimeFocusState, quietHoursContent: (() -> AnyView)? = nil, action: @escaping (ClaudeTimeFocusAction) -> Void) { self.state = state; self.quietHoursContent = quietHoursContent; self.action = action }
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Time and focus").font(.system(size: 15, weight: .semibold)).padding(.bottom, 38)
                Text("Break reminders").padding(.bottom, 7)
                Text("Get a nudge to take a break from Claude. You can snooze or adjust anytime.").foregroundStyle(ClaudePalette.secondary).lineSpacing(4).fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 12) {
                    selector(.hours, label: state.hours.map { "\($0) hr" } ?? "-")
                    selector(.minutes, label: state.minutes.map { "\($0) min" } ?? "-")
                }.padding(.top, 14)
                Divider().padding(.vertical, 20)
                Text("Quiet hours").padding(.bottom, 7)
                Text("Set time limits for Claude. You can dismiss or adjust anytime.").foregroundStyle(ClaudePalette.secondary).lineSpacing(4).fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 12) {
                    ForEach(ClaudeWeekday.allCases, id: \.self) { day in
                        Button { action(.quietDayTapped(day)) } label: { Text(day.initial).font(.system(size: 13, weight: .semibold)).foregroundStyle(ClaudePalette.secondary).frame(width: 34, height: 34).background(ClaudePalette.panel, in: .circle) }.accessibilityLabel(day.rawValue.capitalized).accessibilityIdentifier("settings.focus.day." + day.rawValue)
                    }
                }.padding(.top, 18)
                if let quietHoursContent { quietHoursContent() }
            }.font(.system(size: 15)).padding(.horizontal, 17).padding(.top, 18).padding(.bottom, 24).frame(maxWidth: .infinity, alignment: .leading)
        }.background(colorScheme == .dark ? Color(white: 0.035) : .white).overlay(alignment: .top) { Divider() }.padding(.top, 10)
            .buttonStyle(.plain).accessibilityIdentifier("settings.focus.scroll")
            .sheet(isPresented: Binding(get: { picker != nil }, set: { if !$0 { picker = nil } })) {
                if let picker { pickerSheet(picker) }
            }
    }
    private func selector(_ unit: ClaudeBreakUnit, label: String) -> some View {
        Button { picker = unit } label: {
            HStack { Text(label); Spacer(); Image(systemName: "chevron.down").font(.system(size: 12)).foregroundStyle(ClaudePalette.secondary) }.padding(.horizontal, 12).frame(width: 119, height: 40).background(ClaudePalette.background, in: .rect(cornerRadius: 10)).overlay { RoundedRectangle(cornerRadius: 10).stroke(ClaudePalette.ink.opacity(0.12), lineWidth: 1) }.contentShape(Rectangle())
        }.accessibilityLabel(unit == .hours ? "Break reminder hours" : "Break reminder minutes").accessibilityValue(label).accessibilityIdentifier("settings.focus." + unit.rawValue)
    }
    private func pickerSheet(_ unit: ClaudeBreakUnit) -> some View {
        let values: [Int?] = [nil] + (unit == .hours ? Array(1...12) : [15, 30, 45]).map(Optional.some)
        let selected = unit == .hours ? state.hours : state.minutes
        return ScrollView {
            VStack(spacing: 0) {
                ForEach(values, id: \.self) { value in
                    Button {
                        action(unit == .hours ? .selectHours(value) : .selectMinutes(value)); picker = nil
                    } label: {
                        HStack { Text(value.map { "\($0) \(unit == .hours ? "hr" : "min")" } ?? "-"); Spacer(); if value == selected { Image(systemName: "checkmark").foregroundStyle(.blue) } }.font(.system(size: 15)).padding(.horizontal, 15).frame(height: 40).background(value == selected ? ClaudePalette.ink.opacity(0.07) : .clear, in: .rect(cornerRadius: 10)).contentShape(Rectangle())
                    }.buttonStyle(.plain).accessibilityIdentifier("settings.focus.choice." + (value.map(String.init) ?? "none"))
                }
            }.padding(.horizontal, 5).padding(.top, 38)
        }.foregroundStyle(ClaudePalette.ink).presentationBackground(ClaudePalette.panel).presentationCornerRadius(16).presentationDragIndicator(.visible).presentationDetents([.height(unit == .hours ? 562 : 202)])
    }
}
#endif
