#if canImport(UIKit)
import SwiftUI

public struct ClaudeDispatchView: View {
    @Binding private var state: DispatchState
    private let typography: ClaudeTypography
    private let openSidebar: () -> Void
    private let action: (DispatchAction) -> Void
    public init(state: Binding<DispatchState>, typography: ClaudeTypography = .init(), openSidebar: @escaping () -> Void, action: @escaping (DispatchAction) -> Void) { _state = state; self.typography = typography; self.openSidebar = openSidebar; self.action = action }
    public var body: some View {
        VStack(spacing: 0) {
            header.padding(.horizontal, 16).padding(.top, -2)
            if state.loading {
                Spacer(); HStack(spacing: 9) { ProgressView(); Text("Loading messages").font(.system(size: 15)) }.foregroundStyle(ClaudePalette.secondary).accessibilityIdentifier("dispatch.loading"); Spacer()
            } else if let error = state.error {
                Spacer(); Text(error).multilineTextAlignment(.center).padding(); Button("Try again") { action(.reload) }; Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        ForEach(state.messages) { message in
                            if !message.timestamp.isEmpty {
                                HStack(spacing: 16) {
                                    DispatchWavyLine().stroke(ClaudePalette.secondary.opacity(0.4), lineWidth: 1).frame(height: 5)
                                    Text(message.timestamp).font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary).fixedSize()
                                    DispatchWavyLine().stroke(ClaudePalette.secondary.opacity(0.4), lineWidth: 1).frame(height: 5)
                                }
                            }
                            Text(message.text).font(.custom(typography.serifName, size: 20)).lineSpacing(6).frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading).textSelection(.enabled)
                        }
                    }.padding(.horizontal, 16).padding(.top, 82).padding(.bottom, 24)
                }.scrollDismissesKeyboard(.interactively).accessibilityIdentifier("dispatch.messages")
            }
            composer.padding(.horizontal, 16).padding(.bottom, 8)
        }.foregroundStyle(ClaudePalette.ink)
    }
    private var header: some View {
        ZStack {
            VStack(spacing: 4) {
                Text("Dispatch").font(.system(size: 16, weight: .semibold))
                HStack(spacing: 4) { Circle().frame(width: 7, height: 7); Text(state.connection == .online ? "Online" : state.connection == .offline ? "Offline" : "Unknown").font(.system(size: 12)) }.foregroundStyle(state.connection == .online ? Color.green : ClaudePalette.secondary).padding(.horizontal, 8).padding(.vertical, 3).background(state.connection == .online ? Color.green.opacity(0.15) : Color.gray.opacity(0.1), in: .capsule)
            }
            HStack { Button(action: openSidebar) { UnequalMenu().stroke(ClaudePalette.ink.opacity(0.8), style: StrokeStyle(lineWidth: 1.4, lineCap: .round)).frame(width: 18, height: 17).frame(width: 44, height: 44) }.glassEffect(in: .circle).accessibilityLabel("Open sidebar").accessibilityIdentifier("sidebar.open"); Spacer() }
        }.frame(height: 48)
    }
    private var composer: some View {
        HStack(spacing: 8) {
            Button { action(.attach) } label: { Image(systemName: "plus").font(.system(size: 24, weight: .light)).frame(width: 36, height: 36).background(.white.opacity(0.08), in: .circle) }.buttonStyle(.plain).accessibilityLabel("Add attachment").accessibilityIdentifier("dispatch.attach")
            TextField("Dispatch any task", text: $state.draft, axis: .vertical).font(.system(size: 16)).lineLimit(1...8).accessibilityIdentifier("dispatch.draft")
            Button { action(.submit(state.draft)) } label: { Image(systemName: "arrow.up").font(.system(size: 19)).frame(width: 36, height: 36).background(ClaudePalette.orange, in: .circle) }.buttonStyle(.plain).disabled(state.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty).opacity(state.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1).accessibilityLabel("Send task").accessibilityIdentifier("dispatch.send")
        }.padding(8).glassEffect(in: .rect(cornerRadius: 29))
    }
}
struct ClaudeDispatchBackground: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ClaudePalette.background
                RadialGradient(colors: [Color(red: 0.42, green: 0.23, blue: 0.14).opacity(0.34), .clear], center: UnitPoint(x: 0.5, y: 1.1), startRadius: 0, endRadius: geo.size.height * 0.85)
                Canvas { context, size in
                    var path = Path()
                    for x in stride(from: CGFloat(0), through: size.width, by: 32) { path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: size.height)) }
                    for y in stride(from: CGFloat(0), through: size.height, by: 32) { path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: size.width, y: y)) }
                    context.stroke(path, with: .color(.white.opacity(0.015)), lineWidth: 0.6)
                }
            }
        }
    }
}
private struct DispatchWavyLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: rect.midY))
            for x in stride(from: CGFloat(0), through: rect.width, by: 1) { path.addLine(to: CGPoint(x: x, y: rect.midY + sin(x * .pi / 8) * 1.1)) }
        }
    }
}
#endif
