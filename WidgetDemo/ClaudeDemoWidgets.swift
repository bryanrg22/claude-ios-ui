import SwiftUI
import WidgetKit
import ClaudeWidgets

struct ClaudeWidgetEntry: TimelineEntry { let date: Date }
struct ClaudeWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ClaudeWidgetEntry { .init(date: .now) }
    func getSnapshot(in context: Context, completion: @escaping (ClaudeWidgetEntry) -> Void) { completion(placeholder(in: context)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ClaudeWidgetEntry>) -> Void) { completion(.init(entries: [placeholder(in: context)], policy: .never)) }
}
struct QuickActionsEntryView: View {
    @Environment(\.widgetFamily) private var family
    var body: some View { ClaudeWidgetView(presentation: .init(layout: family == .systemMedium ? .quickActionsMedium : .quickActionsSmall)) }
}
struct ClaudeQuickActionsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ClaudeDemo.QuickActions", provider: ClaudeWidgetProvider()) { _ in QuickActionsEntryView() }
            .configurationDisplayName("Claude Quick Actions").description("Quick access to Claude and image analysis").supportedFamilies([.systemSmall, .systemMedium])
    }
}
struct ClaudeCodeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ClaudeDemo.Code", provider: ClaudeWidgetProvider()) { _ in ClaudeWidgetView(presentation: .init(layout: .codeSmall)) }
            .configurationDisplayName("Code shortcuts").description("Quick access to Claude Code: view your sessions, start a new one, and search").supportedFamilies([.systemSmall])
    }
}
@main struct ClaudeDemoWidgetBundle: WidgetBundle { var body: some Widget { ClaudeQuickActionsWidget(); ClaudeCodeWidget() } }
