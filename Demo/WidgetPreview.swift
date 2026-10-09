import SwiftUI
import ClaudeWidgets

struct WidgetPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Text("Widgets").font(.title2.bold())
                HStack(spacing: 16) {
                    preview(.quickActionsSmall, width: 169)
                    preview(.codeSmall, width: 169)
                }
                preview(.quickActionsMedium, width: 354)
            }.padding(.top, 25)
        }.frame(maxWidth: .infinity).background(Color(white: 0.05)).foregroundStyle(.white)
    }
    private func preview(_ layout: ClaudeWidgetLayout, width: CGFloat) -> some View {
        ClaudeWidgetContent(presentation: .init(layout: layout)).padding(16).frame(width: width, height: 169).background
        { ClaudeWidgetBackground() }.clipShape(.rect(cornerRadius: 24)).overlay {
            RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.12), lineWidth: 0.7)
        }
    }
}
