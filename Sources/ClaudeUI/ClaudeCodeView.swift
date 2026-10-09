#if canImport(UIKit)
    import SwiftUI

    public struct ClaudeCodeView: View {
        @State private var setup = false
        @Binding private var state: CodeState
        private let openSidebar: () -> Void
        private let action: (CodeAction) -> Void
        public init(
            state: Binding<CodeState>, openSidebar: @escaping () -> Void, action: @escaping (CodeAction) -> Void
        ) {
            _state = state
            self.openSidebar = openSidebar
            self.action = action
        }
        public var body: some View {
            if state.showingNewSession {
                ClaudeCodeDraftView(state: $state.draft, back: { action(.closeNewSession) }) { action(.editor($0)) }
            } else if state.showingRoutines {
                ClaudeRoutinesView(state: $state.routines, back: { action(.closeRoutines) }) { action(.routines($0)) }
            } else {
                home
            }
        }
        private var home: some View {
            VStack(spacing: 0) {
                header.padding(.horizontal, 16).padding(.top, -2)
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Devices").font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary).padding(
                            .top, 33
                        ).padding(.bottom, 18)
                        ForEach(state.devices) { device in
                            Button {
                                action(.openDevice(device.id))
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "laptopcomputer")
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(device.name)
                                        if !device.detail.isEmpty {
                                            Text(device.detail).font(.system(size: 15)).foregroundStyle(
                                                ClaudePalette.secondary)
                                        }
                                    }
                                }.frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 10)
                            }.buttonStyle(.plain).accessibilityIdentifier("code.device.\(device.id)")
                        }
                        Button {
                            action(.addDevice)
                            setup = true
                        } label: {
                            Label("Add device", systemImage: "plus").font(.system(size: 16)).padding(.horizontal, 16)
                                .frame(height: 44)
                        }.glassEffect(in: .capsule).accessibilityIdentifier("code.add-device")
                        Text("Sessions").font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary).padding(
                            .top, 30
                        ).padding(.bottom, 26)
                        LazyVStack(spacing: 0) { ForEach(state.visibleSessions) { session in sessionRow(session) } }
                    }.padding(.horizontal, 24).padding(.bottom, 70)
                }.scrollIndicators(.hidden).accessibilityIdentifier("code.sessions")
            }.foregroundStyle(ClaudePalette.ink).background(ClaudePalette.codeBackground)
                .sheet(isPresented: $setup) { ClaudeCodeRemoteSetupSheet { action(.copyRemoteCommand) } }
                .overlay(alignment: .bottom) { bottomControls.padding(.horizontal, 24).padding(.bottom, 0) }
        }
        private var header: some View {
            ZStack {
                Text("Code").font(.system(size: 17, weight: .semibold))
                HStack {
                    Button(action: openSidebar) {
                        UnequalMenu().stroke(
                            ClaudePalette.ink.opacity(0.8), style: StrokeStyle(lineWidth: 1.4, lineCap: .round)
                        ).frame(width: 18, height: 17).frame(width: 44, height: 44)
                    }.glassEffect(in: .circle).accessibilityLabel("Open sidebar").accessibilityIdentifier(
                        "sidebar.open")
                    Spacer()
                    HStack(spacing: 0) {
                        Button {
                            action(.openRoutines)
                        } label: {
                            Image(systemName: "clock").font(.system(size: 19, weight: .light)).frame(
                                width: 48, height: 44)
                        }.accessibilityLabel("Routines").accessibilityIdentifier("code.routines")
                        Menu {
                            Picker(
                                "Filter", selection: Binding(get: { state.filter }, set: { action(.selectFilter($0)) })
                            ) {
                                ForEach(CodeFilter.allCases, id: \.self) { filter in
                                    Label {
                                        Text(filter.rawValue)
                                    } icon: {
                                        filter.icon
                                    }.tag(filter).accessibilityIdentifier("code.filter.\(filter.rawValue)")
                                }
                            }.pickerStyle(.inline)
                        } label: {
                            Image(systemName: "slider.vertical.3").font(.system(size: 20, weight: .light)).frame(
                                width: 48, height: 44)
                        }.accessibilityLabel("Filter sessions").accessibilityIdentifier("code.filter")
                    }.padding(.horizontal, 7).glassEffect(in: .capsule)
                }
            }.frame(height: 48)
        }
        private func sessionRow(_ session: CodeSession) -> some View {
            Button {
                action(.openSession(session.id))
            } label: {
                HStack(alignment: .top, spacing: 20) {
                    statusIcon(session.status).frame(width: 20, height: 24)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(session.title).font(.system(size: 18)).lineLimit(1)
                        HStack(spacing: 6) {
                            Text(session.detail).font(.system(size: 15)).lineLimit(1)
                            if session.location != .none {
                                Image(
                                    systemName: session.location == .cloud
                                        ? "cloud"
                                        : session.location == .connectedComputer
                                            ? "laptopcomputer" : "laptopcomputer.slash"
                                ).font(.system(size: 15, weight: .light)).foregroundStyle(
                                    session.location == .connectedComputer
                                        ? Color.green.opacity(0.7) : ClaudePalette.secondary)
                            }
                        }.foregroundStyle(ClaudePalette.secondary)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }.frame(height: 71, alignment: .top).contentShape(.rect)
            }.buttonStyle(.plain).accessibilityIdentifier("code.session.\(session.id)")
        }
        @ViewBuilder private func statusIcon(_ status: CodeSessionStatus) -> some View {
            switch status {
            case .working: CodeReferenceIcons.workingIndicator.foregroundStyle(ClaudePalette.ink)
            case .needsInput:
                Image(systemName: "hand.raised").font(.system(size: 16)).foregroundStyle(
                    Color(red: 0.72, green: 0.48, blue: 0.12))
            case .readyForReview:
                Image(systemName: "eye").font(.system(size: 16)).foregroundStyle(ClaudePalette.secondary)
            case .completed:
                Image(systemName: "checkmark.circle").font(.system(size: 16)).foregroundStyle(ClaudePalette.secondary)
            case .idle:
                Circle().stroke(ClaudePalette.ink.opacity(0.8), lineWidth: 1.5).frame(width: 8, height: 8).frame(
                    height: 24)
            }
        }
        private var bottomControls: some View {
            HStack {
                Button {
                    action(.search)
                } label: {
                    Image(systemName: "magnifyingglass").font(.system(size: 20, weight: .light)).frame(
                        width: 44, height: 44)
                }.glassEffect(in: .circle).accessibilityLabel("Search sessions").accessibilityIdentifier("code.search")
                Spacer()
                Button {
                    action(.newSession)
                } label: {
                    Label("New session", systemImage: "plus").font(.system(size: 16)).foregroundStyle(.black).padding(
                        .horizontal, 17
                    ).frame(height: 44).background(.white, in: .capsule)
                }.accessibilityIdentifier("code.new-session")
            }
        }
    }
    private struct ClaudeCodeRemoteSetupSheet: View {
        let copy: () -> Void
        @Environment(\.dismiss) private var dismiss
        var body: some View {
            VStack {
                SheetHeader(
                    title: "Set up remote control", controlDiameter: 44, titleMaxWidth: 275, close: { dismiss() })
                Spacer()
                Text(
                    "In a terminal, open the project you want Claude to work in and run this command to connect your device:"
                ).font(.system(size: 17)).multilineTextAlignment(.center).padding(.horizontal, 24)
                Button(action: copy) {
                    HStack(spacing: 8) {
                        Text("claude").foregroundStyle(ClaudePalette.orange)
                        Text("rc")
                        Image(systemName: "square.on.square").font(.system(size: 15))
                    }.font(.system(size: 17, design: .monospaced)).padding(.horizontal, 16).frame(height: 38)
                        .background(ClaudePalette.panel, in: .rect(cornerRadius: 15))
                }.accessibilityIdentifier("code.remote.copy").padding(.top, 16)
                Spacer()
            }.foregroundStyle(ClaudePalette.ink).background(ClaudePalette.background).presentationDetents([.height(415)]
            ).presentationDragIndicator(.visible).presentationCornerRadius(38)
        }
    }
    private extension CodeFilter {
        @MainActor var icon: Image {
            if self == .all { return CodeReferenceIcons.image(.checklist) }
            if self == .working { return CodeReferenceIcons.image(.working) }
            return Image(systemName: symbol)
        }
        var symbol: String {
            switch self {
            case .all: "checklist"
            case .needsInput: "hand.raised"
            case .readyForReview: "eye"
            case .working: "circle.dotted"
            case .completed: "checkmark.circle"
            case .archived: "archivebox"
            }
        }
    }
#endif
