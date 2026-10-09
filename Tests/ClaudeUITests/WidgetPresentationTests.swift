import Foundation
import Testing
import ClaudeWidgets

@Test func widgetDestinationsRoundTripAndRejectNoncanonicalURLs() {
    for destination in ClaudeWidgetDestination.allCases { #expect(ClaudeWidgetDestination(url: destination.url) == destination) }
    for raw in ["https://widget/chat", "claude-ui-demo://other/chat", "claude-ui-demo://widget/chat?extra=true", "claude-ui-demo://widget/chat#fragment", "claude-ui-demo://widget/chat/", "claude-ui-demo://user@widget/chat", "claude-ui-demo://widget:80/chat", "claude-ui-demo://widget/unknown", "claude-ui-demo://widget/code/other"] { #expect(ClaudeWidgetDestination(url: URL(string: raw)!) == nil) }
}
@Test func observedWidgetLayoutsExposeOnlyCapturedActions() {
    #expect(ClaudeWidgetPresentation(layout: .quickActionsSmall).shortcuts == [.camera, .voice])
    #expect(ClaudeWidgetPresentation(layout: .quickActionsMedium).shortcuts == [.camera, .voice, .code, .dispatch])
    #expect(ClaudeWidgetPresentation(layout: .codeSmall).shortcuts == [.newCodeSession, .searchCode])
    #expect(ClaudeWidgetPresentation(layout: .codeSmall).primary == .code)
    #expect(ClaudeWidgetPresentation(layout: .quickActionsMedium).primary == .chat)
}
