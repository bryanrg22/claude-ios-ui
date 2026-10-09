#if canImport(UIKit)
import SwiftUI

struct SheetHeader: View {
    let title: String
    var back = false
    var trailing: String?
    var controlDiameter: CGFloat = 42
    var titleMaxWidth: CGFloat = 200
    let close: () -> Void
    var trailingAction: (() -> Void)?
    var body: some View {
        ZStack {
            Text(title).font(.system(size: 17, weight: .semibold)).lineLimit(1).frame(maxWidth: titleMaxWidth)
            HStack {
                Button(action: close) { Image(systemName: back ? "chevron.left" : "xmark").font(.system(size: 21, weight: .light)).frame(width: controlDiameter, height: controlDiameter) }.glassEffect(in: .circle).accessibilityLabel(back ? "Back" : "Close").accessibilityIdentifier("sheet.close.\(title)")
                Spacer()
                if let trailing { Button(trailing) { trailingAction?() }.font(.system(size: 16)) }
            }
        }.frame(height: 58).padding(.horizontal, 16).padding(.top, 7)
    }
}
struct SheetRow: View {
    let title: String
    var symbol: String?
    var detail: String?
    var value: String?
    var checked = false
    var chevron = false
    var badge: String?
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let symbol { Image(systemName: symbol).font(.system(size: 20, weight: .light)).frame(width: 23).foregroundStyle(Color(white: 0.72)) }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) { Text(title).font(.system(size: 17)); if let badge { Text(badge).font(.system(size: 11, weight: .semibold)).foregroundStyle(badge.contains("usage") ? Color.orange : ClaudePalette.ink).padding(.horizontal, 8).padding(.vertical, 5).background(badge.contains("usage") ? Color.orange.opacity(0.20) : .primary.opacity(0.05), in: .capsule) } }
                    if let detail { Text(detail).font(.system(size: 13)).foregroundStyle(ClaudePalette.secondary).fixedSize(horizontal: false, vertical: true) }
                }.frame(maxWidth: .infinity, alignment: .leading)
                if let value { Text(value).font(.system(size: 16)).foregroundStyle(ClaudePalette.secondary).lineLimit(1) }
                if checked { Image(systemName: "checkmark").font(.system(size: 19, weight: .semibold)).foregroundStyle(.blue) }
                if chevron { Image(systemName: "chevron.right").font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary) }
            }.padding(.horizontal, 16).padding(.vertical, detail == nil ? 14 : 14).contentShape(.rect)
        }.buttonStyle(.plain)
    }
}
struct RowGroup<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View { VStack(spacing: 0, content: content).background(ClaudePalette.panel, in: .rect(cornerRadius: 28)) }
}
struct RowDivider: View { var body: some View { Divider().padding(.horizontal, 16) } }
struct ClaudeModelSheet: View {
    @Binding var state: SessionState
    let action: (ClaudeAction) -> Void
    var voiceContext = false
    var close: (() -> Void)?
    private func closePicker() { if let close { close() } else { dismiss() } }
    @Environment(\.dismiss) private var dismiss
    @State private var effort = false
    var body: some View {
        VStack(spacing: 18) {
            SheetHeader(title: effort ? "Effort" : "Select model", back: effort || voiceContext) { if effort { effort = false } else { closePicker() } }
            if effort {
                VStack(alignment: .leading, spacing: 9) {
                    RowGroup { ForEach(Effort.allCases, id: \.self) { level in
                        SheetRow(title: level.rawValue, checked: state.effort == level, badge: level == .medium ? "Recommended" : level == .max ? "4× or more usage" : nil) { action(.selectEffort(level)); effort = false }.accessibilityIdentifier("effort.\(level.rawValue)")
                        if level != .max { RowDivider() }
                    } }
                    Text("Higher effort means more thorough responses, but takes longer and uses your limits faster.").font(.system(size: 14)).foregroundStyle(ClaudePalette.secondary).padding(.horizontal, 16)
                }.padding(.horizontal, 16)
            } else {
                RowGroup { ForEach(ClaudeModel.allCases, id: \.self) { model in
                    SheetRow(title: voiceContext ? model.rawValue.components(separatedBy: " ")[0] : model.rawValue, detail: model.detail, checked: state.model == model) { action(.selectModel(model)); closePicker() }.accessibilityIdentifier("model.\(model.rawValue)")
                    if model != .haiku { RowDivider() }
                } }.padding(.horizontal, 16)
                RowGroup { SheetRow(title: "Effort", value: state.effort.rawValue, chevron: true) { effort = true }.accessibilityIdentifier("model.effort") }.padding(.horizontal, 16)
            }
            Spacer(minLength: 0)
        }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink).presentationDetents([.height(430)]).presentationDragIndicator(.visible).presentationCornerRadius(38)
    }
}
struct ClaudeAttachmentSheet: View {
    @Binding var state: SessionState
    let mediaContent: (ClaudeMedia, ClaudeMediaPresentation) -> AnyView
    let action: (ClaudeAction) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var page = "Add to session"
    @State private var camera = false
    @State private var pendingCapture: CameraCapture?
    var body: some View {
        VStack(spacing: 16) {
            SheetHeader(title: page, back: page != "Add to session", trailing: page == "Add to session" ? "Photos" : nil, close: { if page == "Add to session" { dismiss() } else { page = "Add to session" } }, trailingAction: { action(.media(.requestPhotos)) })
            switch page {
            case "Select mode":
                RowGroup {
                    SheetRow(title: "Manually approve", symbol: "hand.raised", detail: "Claude asks before using new tools or opening new sites.", checked: !state.automaticApproval) { action(.setAutomaticApproval(false)); page = "Add to session" }
                    RowDivider()
                    SheetRow(title: "Automatically approve", symbol: "forward", detail: "Claude runs on its own and pauses to ask if anything looks unsafe.", checked: state.automaticApproval) { action(.setAutomaticApproval(true)); page = "Add to session" }
                }.padding(.horizontal, 16)
            case "Devices":
                VStack(alignment: .leading, spacing: 9) {
                    RowGroup { SheetRow(title: "Claude Desktop (macOS)", detail: "Last seen 9 hours ago", checked: state.deviceEnabled, badge: "Default") { action(.setDeviceEnabled(!state.deviceEnabled)) } }
                    Text("Starting with your next message, Claude can use the selected computer. Deselect it to work without one.").font(.system(size: 14)).foregroundStyle(ClaudePalette.secondary).padding(.horizontal, 16)
                }.padding(.horizontal, 16)
            case "Add to project":
                RowGroup { ForEach(["None", "Design ideas", "Personal projects"], id: \.self) { name in SheetRow(title: name, symbol: "rectangle.stack") { if name != "None" { action(.attach(name)) }; dismiss() }; if name != "Personal projects" { RowDivider() } } }.padding(.horizontal, 16)
            case "Photos", "Add files":
                VStack(spacing: 16) {
                    Image(systemName: page == "Add files" ? "doc" : "photo").font(.system(size: 40)).foregroundStyle(ClaudePalette.secondary)
                    Text(page == "Camera" ? "Camera preview" : "Choose a sample attachment").font(.title3)
                    Text("Offline demo • no access to your files or camera").font(.footnote).foregroundStyle(ClaudePalette.secondary)
                    Button("Add sample \(page == "Add files" ? "document" : "photo")") { action(.attach(page == "Add files" ? "Notes.pdf" : "Photo.jpg")); dismiss() }.buttonStyle(.borderedProminent).tint(ClaudePalette.orange)
                }.frame(maxWidth: .infinity).padding(.top, 40)
            default:
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        Button { camera = true } label: { VStack(spacing: 7) { Image(systemName: "camera").font(.system(size: 22)); Text("Camera").font(.system(size: 17)) }.frame(width: 100, height: 100).background(ClaudePalette.panel, in: .rect(cornerRadius: 28)) }
                        ForEach(state.media.recent) { item in
                            Button { action(.media(.toggleRecent(item.id))) } label: {
                                mediaContent(item, .thumbnail).frame(width: 100, height: 100).clipped().clipShape(.rect(cornerRadius: 28))
                                    .overlay(alignment: .topTrailing) { if state.media.selectedIDs.contains(item.id) { Image(systemName: "checkmark").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white).frame(width: 26, height: 26).background(.black, in: .circle).padding(7) } }
                            }.accessibilityLabel(item.accessibilityDescription).accessibilityValue(state.media.selectedIDs.contains(item.id) ? "Selected" : "Not selected").accessibilityIdentifier("media.recent." + item.id)
                        }
                    }.padding(.horizontal, 16)
                }.scrollIndicators(.hidden)
                RowGroup {
                    SheetRow(title: "Add files", symbol: "doc.badge.arrow.up") { page = "Add files" }; RowDivider()
                    SheetRow(title: "Add to project", symbol: "rectangle.stack", value: "None", chevron: true) { page = "Add to project" }
                }.padding(.horizontal, 16)
                RowGroup {
                    SheetRow(title: "Permission", symbol: "hand.raised", value: state.automaticApproval ? "Automatic" : "Manual", chevron: true) { page = "Select mode" }; RowDivider()
                    SheetRow(title: "Devices", symbol: "desktopcomputer", value: state.deviceEnabled ? "Claude Desktop (…)" : "None", chevron: true) { page = "Devices" }
                }.padding(.horizontal, 16)
            }
            Spacer(minLength: 0)
        }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink).presentationDetents([.height(430)]).presentationDragIndicator(.visible).presentationCornerRadius(38)
            .overlay(alignment: .bottom) {
                if page == "Add to session", !state.media.selected.isEmpty {
                    Button { action(.media(.attachSelected)); dismiss() } label: { Text("Attach \(state.media.selected.count) \(state.media.selected.count == 1 ? "photo" : "photos")").font(.system(size: 16, weight: .medium)).frame(maxWidth: .infinity).frame(height: 46).foregroundStyle(ClaudePalette.background).background(ClaudePalette.ink, in: .capsule) }.padding(.horizontal, 16).padding(.bottom, 16).accessibilityIdentifier("media.attachSelected")
                }
            }
            .onAppear { action(.media(.beginSelection)) }.onDisappear { action(.media(.cancelSelection)) }
            .fullScreenCover(isPresented: $camera, onDismiss: {
                if let capture = pendingCapture { action(.attach(capture.mode == .photo ? "Camera photo.jpg" : "Camera video.mov")); pendingCapture = nil; dismiss() }
            }) {
                ClaudeCameraView(onCancel: { camera = false }, onCapture: { capture in pendingCapture = capture; camera = false }) { SyntheticCameraPreview() }
            }
    }
}
struct SyntheticPhoto: View {
    let index: Int
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [Color(red: 0.40, green: 0.59, blue: 0.68), Color(red: 0.77, green: 0.77, blue: 0.59)], startPoint: .top, endPoint: .bottom)
                Circle().fill(Color(white: 0.95).opacity(0.85)).frame(width: 19, height: 19).offset(x: 21, y: -22)
                Path { p in p.move(to: CGPoint(x: 0, y: geo.size.height)); p.addLine(to: CGPoint(x: 0, y: 70)); p.addLine(to: CGPoint(x: 28, y: 36 + index * 7)); p.addLine(to: CGPoint(x: 62, y: 72)); p.addLine(to: CGPoint(x: 84, y: 40)); p.addLine(to: CGPoint(x: geo.size.width, y: 68)); p.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height)); p.closeSubpath() }.fill(Color(red: 0.20, green: 0.35, blue: 0.29))
            }
        }
    }
}
struct ClaudePlaceholderSheet: View {
    let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var enabled = true
    var body: some View {
        VStack(spacing: 20) {
            SheetHeader(title: title, close: { dismiss() })
            if ["Notifications", "Privacy", "Capabilities", "Time & focus"].contains(title) {
                Toggle("\(title) enabled", isOn: $enabled).padding().background(ClaudePalette.panel, in: .rect(cornerRadius: 24)).padding(.horizontal, 16)
            } else if title == "Search sessions" {
                TextField("Search", text: .constant("")).textFieldStyle(.roundedBorder).padding()
            } else {
                Image(systemName: "rectangle.on.rectangle").font(.system(size: 34)).foregroundStyle(ClaudePalette.secondary).padding(.top, 35)
                Text("\(title)").font(.title2)
            }
            Text("This destination is a demo placeholder. Its complete reference interface has not been captured yet.").font(.footnote).foregroundStyle(ClaudePalette.secondary).multilineTextAlignment(.center).padding(.horizontal, 30)
            Spacer()
        }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink)
    }
}
struct ThemeThumbnail: View {
    let appearance: ClaudeAppearance
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                (appearance == .dark ? Color(white: 0.08) : Color.white)
                if appearance == .system { Path { p in p.move(to: CGPoint(x: geo.size.width, y: 0)); p.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height)); p.addLine(to: CGPoint(x: 0, y: geo.size.height)); p.closeSubpath() }.fill(Color(white: 0.08)) }
                RoundedRectangle(cornerRadius: 9).stroke(.gray.opacity(0.3), lineWidth: 0.7).padding(8)
                VStack(alignment: .leading, spacing: 4) { Capsule().frame(width: 39, height: 3); Capsule().frame(width: 27, height: 3) }.foregroundStyle(.gray).padding(16)
                Circle().fill(Color(red: 0.85, green: 0.47, blue: 0.34)).frame(width: 12, height: 12).position(x: geo.size.width - 20, y: geo.size.height - 20)
            }.clipShape(.rect(cornerRadius: 14)).overlay { RoundedRectangle(cornerRadius: 14).stroke(.gray.opacity(0.2), lineWidth: 0.6) }
        }
    }
}
struct ClaudeFeedbackSheet: View {
    let positive: Bool
    var submit: (FeedbackSubmission) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var comment = ""
    @State private var category = "Other"
    private let categories = ["Other", "UI bug", "Harmful content", "Overactive refusal", "Did not fully follow my request", "Not factually correct", "Incomplete response", "Issue with memory"]
    var body: some View {
        VStack(spacing: 18) {
            SheetHeader(title: "Feedback", trailing: "✓", close: { dismiss() }, trailingAction: { submit(FeedbackSubmission(positive: positive, comment: comment, issue: category)); dismiss() })
            if !positive { HStack { Text("Type of issue"); Spacer(); Picker("Type of issue", selection: $category) { ForEach(categories, id: \.self) { Text($0) } } }.padding(.horizontal, 22) }
            ZStack(alignment: .topLeading) {
                TextEditor(text: $comment).scrollContentBackground(.hidden).padding(10)
                if comment.isEmpty { Text(positive ? "What was satisfying about this response?" : "What was unsatisfying about this response?").foregroundStyle(ClaudePalette.secondary).padding(18).allowsHitTesting(false) }
            }.frame(height: positive ? 185 : 150).background(ClaudePalette.panel, in: .rect(cornerRadius: 24)).padding(.horizontal, 16)
            Text("Your feedback helps improve Claude. This demo keeps feedback on this device.").font(.footnote).foregroundStyle(ClaudePalette.secondary).padding(.horizontal, 24)
            Spacer()
        }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink).presentationDetents([.height(430)]).presentationDragIndicator(.visible).presentationCornerRadius(38)
    }
}
#endif
