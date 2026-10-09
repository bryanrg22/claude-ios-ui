#if canImport(UIKit)
import SwiftUI

public struct ClaudeProjectsView: View {
    @Binding private var state: ProjectState
    private let openSidebar: () -> Void
    private let action: (ProjectAction) -> Void
    private let typography: ClaudeTypography
    @State private var notice: String?
    public init(state: Binding<ProjectState>, typography: ClaudeTypography = .init(), openSidebar: @escaping () -> Void, action: @escaping (ProjectAction) -> Void) { _state = state; self.typography = typography; self.openSidebar = openSidebar; self.action = action }
    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Projects").font(.system(size: 17, weight: .semibold))
                HStack {
                    Button(action: openSidebar) { VStack(alignment: .leading, spacing: 5) { Capsule().frame(width: 20, height: 1.5); Capsule().frame(width: 14, height: 1.5) }.frame(width: 44, height: 44) }.glassEffect(in: .circle).accessibilityLabel("Open sidebar").accessibilityIdentifier("projects.sidebar")
                    Spacer()
                    Menu {
                        Picker("Project filter", selection: Binding(get: { state.filter }, set: { action(.selectFilter($0)) })) {
                            Label("Pinned", systemImage: "pin").tag(ProjectFilter.pinned)
                            Label("Yours", systemImage: "person").tag(ProjectFilter.yours)
                        }.pickerStyle(.inline)
                        Divider()
                        Button { action(.openArchived); notice = "The archived Projects screen has not been captured yet." } label: { Label("Archived", systemImage: "archivebox") }
                    } label: { Image(systemName: "slider.vertical.3").font(.system(size: 20, weight: .light)).frame(width: 44, height: 44) }.menuOrder(.fixed).glassEffect(in: .circle).accessibilityLabel("Filter projects").accessibilityIdentifier("projects.filter")
                }
            }.frame(height: 48).padding(.horizontal, 16).padding(.top, -2)
            if state.visibleProjects.isEmpty {
                GeometryReader { geometry in
                    VStack(spacing: 18) {
                        ProjectOutlineIcon().frame(width: 23, height: 23).frame(width: 48, height: 48).background(ClaudePalette.panel, in: .circle)
                        VStack(spacing: 4) { Text("No projects yet").font(.system(size: 18)); Text("Create one to organize sessions around a topic or set of documents.").font(.system(size: 16)).multilineTextAlignment(.center) }
                    }.foregroundStyle(ClaudePalette.secondary).padding(.horizontal, 32).frame(maxWidth: .infinity).position(x: geometry.size.width / 2, y: geometry.size.height * 0.505)
                }
            } else {
                // Host-injected population is functional; its source layout remains uncaptured.
                ScrollView { VStack(spacing: 0) { ForEach(state.visibleProjects) { project in Button { action(.openProject(project.id)) } label: { HStack(spacing: 14) { Image(systemName: project.icon); Text(project.name); Spacer() }.padding(18).contentShape(Rectangle()) } } } }
            }
            HStack { Spacer(); Button { action(.begin) } label: { Label("New project", systemImage: "plus").font(.system(size: 16)).foregroundStyle(.black).padding(.horizontal, 17).frame(height: 44).background(.white, in: .capsule) }.accessibilityIdentifier("projects.new") }.padding(.horizontal, 24)
        }.foregroundStyle(ClaudePalette.ink).background(ClaudePalette.codeBackground).buttonStyle(.plain)
            .sheet(isPresented: Binding(get: { state.editor != nil }, set: { if !$0 { action(.cancel) } })) { ClaudeProjectEditorView(state: $state, typography: typography, action: action) }
            .alert("UI reference needed", isPresented: Binding(get: { notice != nil }, set: { if !$0 { notice = nil } })) { Button("OK") { notice = nil } } message: { Text(notice ?? "") }
    }
}
struct ProjectOutlineIcon: View {
    var body: some View {
        GeometryReader { geo in
            Path { p in
                let w = geo.size.width, h = geo.size.height
                p.move(to: CGPoint(x: w * 0.28, y: h * 0.06)); p.addLine(to: CGPoint(x: w * 0.72, y: h * 0.06))
                p.move(to: CGPoint(x: w * 0.19, y: h * 0.24)); p.addLine(to: CGPoint(x: w * 0.81, y: h * 0.24))
                p.move(to: CGPoint(x: w * 0.1, y: h * 0.4)); p.addLine(to: CGPoint(x: w * 0.9, y: h * 0.4)); p.addLine(to: CGPoint(x: w * 0.81, y: h * 0.95)); p.addLine(to: CGPoint(x: w * 0.19, y: h * 0.95)); p.closeSubpath()
            }.stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
        }
    }
}
#endif
