#if canImport(UIKit)
import SwiftUI

struct ClaudeProjectEditorView: View {
    @Binding var state: ProjectState
    let typography: ClaudeTypography
    let action: (ProjectAction) -> Void
    @State private var notice: String?
    @State private var destination: String?
    @State private var folderLink = ""
    @FocusState private var nameFocused: Bool
    var body: some View {
        Group {
            if destination == "icons" {
                ClaudeProjectIconPicker(initialSymbol: state.draft.icon, initialColor: state.draft.iconColor, back: { destination = nil }) { symbol, color in action(.selectIcon(symbol)); action(.selectIconColor(color)); destination = nil }
            } else if destination == "drive" { drivePicker }
            else if state.editor == .introduction { introduction }
            else { form }
        }.foregroundStyle(ClaudePalette.ink).background(ClaudePalette.background).buttonStyle(.plain)
            .presentationDetents([.large]).presentationDragIndicator(.hidden)
            .alert("UI reference needed", isPresented: Binding(get: { notice != nil }, set: { if !$0 { notice = nil } })) { Button("OK") { notice = nil } } message: { Text(notice ?? "") }
    }
    private var introduction: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ProjectIntroductionIllustration().frame(width: 215, height: 254).frame(maxWidth: .infinity).padding(.top, 24)
                    Text("A project is now a conversation with Claude").font(.custom(typography.serifName, size: 32)).fixedSize(horizontal: false, vertical: true)
                    Text("A project used to be a folder. Now it's one ongoing chat. Ask for things as they come up, and Claude works on each one in a thread and reports back as it goes.").font(.system(size: 16)).lineSpacing(3)
                    VStack(alignment: .leading, spacing: 18) {
                        explanation("bubble.left", "One conversation that branches into threads when the work needs it")
                        explanation("arrow.trianglehead.counterclockwise", "Every thread knows your repositories, instructions, and what came before")
                        explanation("cloud", "Close the app and threads keep going")
                    }
                }.padding(.horizontal, 24).padding(.bottom, 24)
            }.scrollIndicators(.hidden)
            Button { action(.continueIntroduction) } label: { Text("Continue").font(.system(size: 18, weight: .semibold)).foregroundStyle(.black).frame(maxWidth: .infinity).frame(height: 48).background(.white, in: .capsule) }.padding(.horizontal, 16).padding(.bottom, 16).accessibilityIdentifier("project.introduction.continue")
        }.overlay(alignment: .topLeading) { closeButton.padding(16) }
    }
    private func explanation(_ symbol: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 18) { Image(systemName: symbol).font(.system(size: 20, weight: .light)).frame(width: 22); Text(text).font(.system(size: 17)).lineSpacing(3) }
    }
    private var closeButton: some View { Button { action(.cancel) } label: { Image(systemName: "xmark").font(.system(size: 23, weight: .light)).frame(width: 44, height: 44) }.glassEffect(in: .circle).accessibilityLabel("Cancel new project").accessibilityIdentifier("project.cancel") }
    private var form: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("New project").font(.system(size: 17, weight: .semibold))
                HStack {
                    closeButton; Spacer()
                    Button { if let draft = state.validatedDraft { action(.create(draft)) } } label: { Image(systemName: "checkmark").font(.system(size: 23, weight: .light)).frame(width: 44, height: 44).background(.white.opacity(state.canCreate ? 1 : 0.35), in: .circle).foregroundStyle(state.canCreate ? .black : .white) }.disabled(!state.canCreate).accessibilityLabel("Create project").accessibilityIdentifier("project.create")
                }
            }.frame(height: 48).padding(.horizontal, 16).padding(.top, 16)
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        fieldLabel("Name")
                        HStack(spacing: 8) {
                            Button { nameFocused = false; action(.openIconPicker); destination = "icons" } label: { Group { if state.draft.icon == "rectangle.stack" { ProjectOutlineIcon() } else { Image(systemName: state.draft.icon).resizable().scaledToFit() } }.frame(width: 22, height: 22).foregroundStyle(ProjectIconColors.value(state.draft.iconColor)).frame(width: 34, height: 34).background(.white.opacity(0.03), in: .rect(cornerRadius: 12)) }.accessibilityLabel("Project icon").accessibilityIdentifier("project.icon")
                            TextField("Project name...", text: Binding(get: { state.draft.name }, set: { action(.editName($0)) })).font(.system(size: 18)).focused($nameFocused).submitLabel(.done).onSubmit { nameFocused = false }.accessibilityIdentifier("project.name")
                        }.padding(.horizontal, 16).frame(height: 62).background(ClaudePalette.panel, in: .rect(cornerRadius: 28))
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        fieldLabel("Goal (optional)")
                        ZStack(alignment: .topLeading) {
                            if state.draft.goal.isEmpty { Text("Finalize the Q3 launch plan").font(.system(size: 18)).foregroundStyle(ClaudePalette.secondary.opacity(0.65)).padding(16).allowsHitTesting(false) }
                            TextEditor(text: Binding(get: { state.draft.goal }, set: { action(.editGoal($0)) })).font(.system(size: 18)).scrollContentBackground(.hidden).padding(10).accessibilityIdentifier("project.goal")
                        }.frame(height: 96).background(ClaudePalette.panel, in: .rect(cornerRadius: 28))
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        fieldLabel("Context (optional)")
                        Menu {
                            Button { action(.openContextSource("Repository")); notice = "The Projects repository picker has not been captured yet." } label: { Label { Text("Repository") } icon: { CodeReferenceIcons.image(.branch) } }
                            Button { nameFocused = false; action(.openContextSource("Google Drive")); folderLink = ""; destination = "drive" } label: { Label("Google Drive", systemImage: "triangle") }
                        } label: { HStack(spacing: 12) { Image(systemName: "plus").font(.system(size: 23, weight: .light)); Text("Add context"); Spacer() }.padding(.horizontal, 20).frame(height: 54).background(ClaudePalette.panel, in: .capsule).contentShape(Capsule()) }.menuOrder(.fixed).accessibilityIdentifier("project.context")
                        ForEach(state.draft.context, id: \.self) { item in HStack { CodeReferenceIcons.image(.branch).frame(width: 20, height: 20); Text(item).lineLimit(1); Spacer(); Button { action(.removeContext(item)) } label: { Image(systemName: "xmark").frame(width: 30, height: 44) }.accessibilityLabel("Remove " + item) }.padding(.horizontal, 20).background(ClaudePalette.panel, in: .capsule) }
                        if !state.suggestedRepository.isEmpty && !state.draft.context.contains(state.suggestedRepository) {
                            Button { action(.addContext(state.suggestedRepository)) } label: { HStack(spacing: 12) { CodeReferenceIcons.image(.branch).frame(width: 20, height: 20); Text(state.suggestedRepository).lineLimit(1); Spacer(); Image(systemName: "plus").font(.system(size: 20, weight: .light)) }.padding(.horizontal, 20).frame(height: 54).overlay { Capsule().stroke(ClaudePalette.ink.opacity(0.09), style: StrokeStyle(lineWidth: 1, dash: [3, 3])) }.contentShape(Capsule()) }.foregroundStyle(ClaudePalette.secondary).accessibilityIdentifier("project.suggested-repository")
                        }
                    }
                    Menu { ForEach(state.environments, id: \.self) { environment in Button { action(.selectEnvironment(environment)) } label: { Label(environment, systemImage: "cloud") } } } label: {
                        HStack(spacing: 12) { Image(systemName: "cloud").font(.system(size: 21, weight: .light)); Text("Environment"); Spacer(); Text(state.draft.environment ?? "Choose").foregroundStyle(ClaudePalette.secondary); Image(systemName: "chevron.up.chevron.down").font(.system(size: 11)).foregroundStyle(ClaudePalette.secondary) }.padding(.horizontal, 20).frame(height: 54).background(ClaudePalette.panel, in: .capsule).contentShape(Capsule())
                    }.menuOrder(.fixed).accessibilityIdentifier("project.environment")
                }.font(.system(size: 18)).padding(.horizontal, 16).padding(.top, 32).padding(.bottom, 20)
            }.scrollDismissesKeyboard(.interactively)
        }
    }
    private var drivePicker: some View {
        VStack(spacing: 12) {
            ZStack {
                Text("Add a Google Drive folder").font(.system(size: 17, weight: .semibold))
                HStack {
                    Button { destination = nil } label: { Image(systemName: "chevron.left").font(.system(size: 23, weight: .light)).frame(width: 44, height: 44) }.glassEffect(in: .circle).accessibilityLabel("Back to new project").accessibilityIdentifier("project.drive.back")
                    Spacer()
                    Button { action(.addContext(folderLink.trimmingCharacters(in: .whitespacesAndNewlines))); destination = nil } label: { Image(systemName: "checkmark").font(.system(size: 23, weight: .light)).frame(width: 44, height: 44).background(.white.opacity(validFolderLink ? 1 : 0.35), in: .circle).foregroundStyle(validFolderLink ? .black : .white) }.disabled(!validFolderLink).accessibilityLabel("Add Google Drive folder").accessibilityIdentifier("project.drive.add")
                }
            }.frame(height: 48).padding(.top, 16)
            TextField("Folder link", text: $folderLink).font(.system(size: 16)).textInputAutocapitalization(.never).autocorrectionDisabled().keyboardType(.URL).padding(.horizontal, 16).frame(height: 48).background(ClaudePalette.panel, in: .capsule).overlay { Capsule().stroke(.white.opacity(0.12), lineWidth: 0.5) }.accessibilityIdentifier("project.drive.link")
            Text("Copy the folder’s link in Google Drive and paste it here.").font(.system(size: 14)).foregroundStyle(ClaudePalette.secondary).frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }.padding(.horizontal, 16)
    }
    private var validFolderLink: Bool { guard let url = URL(string: folderLink.trimmingCharacters(in: .whitespacesAndNewlines)) else { return false }; return url.scheme == "https" && url.host == "drive.google.com" && url.path.contains("/folders/") && !url.lastPathComponent.isEmpty && url.lastPathComponent != "folders" }
    private func fieldLabel(_ title: String) -> some View { Text(title).font(.system(size: 16)).foregroundStyle(ClaudePalette.secondary).padding(.horizontal, 16) }
}
private struct ProjectIntroductionIllustration: View {
    var body: some View {
        VStack(spacing: 10) {
            Capsule().fill(.white.opacity(0.07)).frame(width: 78, height: 16).padding(.top, 10)
            HStack {
                Image(systemName: "chevron.left").frame(width: 28, height: 28).background(.black.opacity(0.75), in: .circle)
                Spacer(); Label("My Stuff", systemImage: "building").font(.system(size: 10, weight: .semibold)).padding(8).background(.black.opacity(0.7), in: .capsule); Spacer()
                Image(systemName: "list.bullet").frame(width: 28, height: 28).background(.black.opacity(0.75), in: .circle)
            }.font(.system(size: 13)).padding(.horizontal, 14)
            Text("Hi Alex, welcome to your new project! You can treat me like a project coordinator. Based on your asks, I’ll either respond to you directly or start threads to work on things in parallel.").font(.system(size: 12)).lineSpacing(3).padding(12).background(.black.opacity(0.8), in: .rect(cornerRadius: 18)).padding(.horizontal, 8)
            HStack { Text("•••").font(.system(size: 18)).padding(.horizontal, 10).padding(.vertical, 2).background(.black.opacity(0.75), in: .capsule); Spacer() }.padding(.horizontal, 8)
            Spacer(minLength: 0)
        }.background(ClaudePalette.panel, in: .rect(cornerRadius: 36)).overlay { RoundedRectangle(cornerRadius: 36).stroke(.white.opacity(0.12)) }.mask { LinearGradient(stops: [.init(color: .white, location: 0), .init(color: .white, location: 0.76), .init(color: .clear, location: 1)], startPoint: .top, endPoint: .bottom) }.accessibilityHidden(true)
    }
}
#endif
