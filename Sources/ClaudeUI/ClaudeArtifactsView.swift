#if canImport(UIKit)
    import SwiftUI

    public struct ClaudeArtifactsView: View {
        @Binding private var state: ArtifactsState
        private let openSidebar: () -> Void
        private let action: (ArtifactAction) -> Void
        private let documentContent: ((ArtifactDocument) -> AnyView)?
        /// Supply custom document rendering if your host has its own rich-text model.
        public init(
            state: Binding<ArtifactsState>, openSidebar: @escaping () -> Void,
            documentContent: ((ArtifactDocument) -> AnyView)? = nil, action: @escaping (ArtifactAction) -> Void
        ) {
            _state = state
            self.openSidebar = openSidebar
            self.documentContent = documentContent
            self.action = action
        }
        public var body: some View {
            VStack(spacing: 0) {
                if let selected = state.selected { viewer(selected) } else { list }
            }.foregroundStyle(ClaudePalette.ink).background(ClaudePalette.codeBackground)
        }
        private var list: some View {
            VStack(spacing: 0) {
                ZStack {
                    Text("Artifacts").font(.system(size: 17, weight: .semibold))
                    HStack {
                        Button(action: openSidebar) {
                            UnequalMenu().stroke(
                                ClaudePalette.ink.opacity(0.8), style: StrokeStyle(lineWidth: 1.4, lineCap: .round)
                            ).frame(width: 18, height: 17).frame(width: 44, height: 44)
                        }.glassEffect(in: .circle).accessibilityLabel("Open sidebar").accessibilityIdentifier(
                            "sidebar.open")
                        Spacer()
                        Menu {
                            Picker(
                                "Ownership",
                                selection: Binding(get: { state.ownership }, set: { action(.ownership($0)) })
                            ) {
                                ForEach(ArtifactOwnership.allCases, id: \.self) { filter in
                                    Label(filter.rawValue, systemImage: filter.symbol).tag(filter)
                                }
                            }.pickerStyle(.inline)
                            Picker("Type", selection: Binding(get: { state.kind }, set: { action(.kind($0)) })) {
                                ForEach(ArtifactKind.allCases, id: \.self) { filter in
                                    Label(filter.rawValue, systemImage: filter.symbol).tag(filter)
                                }
                            }.pickerStyle(.inline)
                        } label: {
                            Image(systemName: "slider.vertical.3").font(.system(size: 20, weight: .light)).frame(
                                width: 44, height: 44)
                        }.menuOrder(.fixed).glassEffect(in: .circle).accessibilityLabel("Filter artifacts")
                            .accessibilityIdentifier("artifacts.filter")
                    }
                }.frame(height: 48).padding(.horizontal, 16).padding(.top, -2)
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(state.visibleItems) { item in
                            Button {
                                action(.open(item.id))
                            } label: {
                                HStack(alignment: .top, spacing: 8) {
                                    preview(item).frame(width: 134, height: 70).clipShape(.rect(cornerRadius: 17))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.title).font(.system(size: 16, weight: .medium)).lineLimit(1)
                                        Label(item.privacy, systemImage: "lock").font(.system(size: 14))
                                            .foregroundStyle(ClaudePalette.secondary)
                                        Spacer(minLength: 0)
                                        Text(item.edited).font(.system(size: 14)).foregroundStyle(
                                            ClaudePalette.secondary
                                        ).lineLimit(1)
                                    }.frame(maxWidth: .infinity, alignment: .leading).frame(height: 70)
                                }.padding(7).overlay {
                                    RoundedRectangle(cornerRadius: 24).stroke(
                                        ClaudePalette.ink.opacity(0.12), lineWidth: 1)
                                }.contentShape(.rect)
                            }.buttonStyle(.plain).accessibilityIdentifier("artifact.row.\(item.id)")
                        }
                    }.padding(.horizontal, 16).padding(.top, 25).padding(.bottom, 60)
                }.scrollIndicators(.hidden)
            }.overlay(alignment: .bottom) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                    TextField("Search", text: Binding(get: { state.query }, set: { action(.search($0)) }))
                        .accessibilityIdentifier("artifacts.search")
                }.font(.system(size: 18)).padding(.horizontal, 16).frame(height: 46).glassEffect(in: .capsule).padding(
                    .horizontal, 28)
            }
        }
        private func preview(_ item: ClaudeArtifact) -> some View {
            ZStack(alignment: .bottomLeading) {
                Rectangle().fill(item.darkPreview ? Color(white: 0.12) : .white)
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.document?.title ?? item.title).font(.custom("Newsreader16pt-Regular", size: 8)).lineLimit(
                        3)
                    if let document = item.document {
                        Text(document.date).font(.system(size: 3))
                        if let section = document.sections.first {
                            Text(section.title).font(.custom("Newsreader16pt-Regular", size: 5))
                            Text(section.paragraphs.first ?? "").font(.system(size: 3)).lineLimit(4)
                        }
                    }
                    Spacer(minLength: 0)
                }.foregroundStyle(item.darkPreview ? .white : .black).padding(10).frame(
                    maxWidth: .infinity, alignment: .leading)
                if item.kind == .docs {
                    Image(systemName: "doc.richtext").font(.system(size: 13)).foregroundStyle(
                        Color(red: 0.38, green: 0.62, blue: 0.88)
                    ).frame(width: 28, height: 28).background(
                        Color(red: 0.01, green: 0.13, blue: 0.24), in: .rect(cornerRadius: 9))
                }
            }
        }
        private func viewer(_ item: ClaudeArtifact) -> some View {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        action(.close)
                    } label: {
                        Image(systemName: "chevron.left").font(.system(size: 22, weight: .light)).frame(
                            width: 44, height: 44)
                    }.glassEffect(in: .circle).accessibilityLabel("Back").accessibilityIdentifier("artifact.back")
                    Spacer()
                    HStack(spacing: 0) {
                        toolbar("arrow.uturn.backward", label: "Undo", id: "undo", enabled: item.canUndo) {
                            action(.undo(item.id))
                        }
                        toolbar("arrow.uturn.forward", label: "Redo", id: "redo", enabled: item.canRedo) {
                            action(.redo(item.id))
                        }
                        toolbar("bubble.left.and.bubble.right", label: "Comments", id: "comments") {
                            action(.comments(item.id))
                        }
                        toolbar("square.and.arrow.up", label: "Share", id: "share") { action(.share(item.id)) }
                    }.padding(.horizontal, 5).glassEffect(in: .capsule)
                }.frame(height: 48).padding(.horizontal, 16).padding(.top, -2)
                ScrollView {
                    if let document = item.document {
                        VStack(alignment: .leading, spacing: 0) {
                            Button {
                                action(.tabs(item.id))
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "doc")
                                    Text(document.tab)
                                    Image(systemName: "chevron.down").font(.system(size: 10)).foregroundStyle(
                                        ClaudePalette.secondary)
                                }.font(.system(size: 16))
                            }.accessibilityIdentifier("artifact.tabs").padding(.bottom, 34)
                            if let documentContent { documentContent(document) } else { defaultDocument(document) }
                        }.padding(.horizontal, 20).padding(.top, 25).padding(.bottom, 32)
                    }
                }.scrollIndicators(.hidden).accessibilityIdentifier("artifact.document")
            }
        }
        private func defaultDocument(_ document: ArtifactDocument) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    action(.toggleTitle)
                } label: {
                    HStack(alignment: .top) {
                        Text(document.title).font(.custom("Newsreader16pt-Regular", size: 36)).multilineTextAlignment(
                            .leading
                        ).frame(maxWidth: .infinity, alignment: .leading)
                        chevron(state.titleCollapsed).padding(.top, 12)
                    }
                }.accessibilityIdentifier("artifact.collapse-title")
                if !state.titleCollapsed {
                    HStack(spacing: 5) {
                        if !document.date.isEmpty {
                            Label(document.date, systemImage: "calendar").padding(.horizontal, 7).padding(.vertical, 2)
                                .background(ClaudePalette.panel, in: .capsule)
                        }
                        if !document.author.isEmpty {
                            Text("·")
                            Text("@\(document.author)").padding(.horizontal, 7).padding(.vertical, 2).background(
                                ClaudePalette.panel, in: .capsule)
                        }
                    }.font(.system(size: 12, weight: .medium)).padding(.top, 13).padding(.bottom, 38)
                    ForEach(document.sections) { section in
                        Button {
                            action(.toggleSection(section.id))
                        } label: {
                            HStack(alignment: .top) {
                                Text(section.title).font(.custom("Newsreader16pt-Regular", size: 26))
                                    .multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                chevron(state.collapsedSections.contains(section.id)).padding(.top, 8)
                            }
                        }.accessibilityIdentifier("artifact.section.\(section.id)").padding(.bottom, 12)
                        if !state.collapsedSections.contains(section.id) {
                            ClaudeMarkdownView(section.paragraphs.joined(separator: "\n\n"), theme: .artifact) {
                                action(.markdown($0))
                            }.padding(.bottom, 12)
                        }
                    }
                }
            }
        }
        private func chevron(_ collapsed: Bool) -> some View {
            Image(systemName: collapsed ? "chevron.right" : "chevron.down").font(.system(size: 12)).foregroundStyle(
                ClaudePalette.secondary
            ).frame(width: 18)
        }
        private func toolbar(
            _ symbol: String, label: String, id: String, enabled: Bool = true, action: @escaping () -> Void
        ) -> some View {
            Button(action: action) {
                Image(systemName: symbol).font(.system(size: 20, weight: .light)).frame(width: 52, height: 44)
            }.disabled(!enabled).opacity(enabled ? 1 : 0.3).accessibilityLabel(label).accessibilityIdentifier(
                "artifact.\(id)")
        }
    }
    private extension ArtifactOwnership {
        var symbol: String {
            switch self {
            case .all: "square.on.circle"
            case .pinned: "pin"
            case .yours: "person"
            case .shared: "person.2"
            }
        }
    }
    private extension ArtifactKind {
        var symbol: String {
            switch self {
            case .all: "square.on.circle"
            case .design, .designSystem: "paintpalette"
            case .docs, .other: "doc.richtext"
            case .slides: "rectangle.on.rectangle"
            }
        }
    }
#endif
