#if canImport(UIKit)
    import SwiftUI

    public enum ClaudeMediaPresentation { case thumbnail, message, viewer, videoViewer }
    public struct ClaudeMediaPlaceholder: View {
        public init() {}
        public var body: some View {
            Rectangle().fill(.gray.opacity(0.2)).overlay { Image(systemName: "photo").foregroundStyle(.secondary) }
        }
    }
    /// Pixels are injected by the host. This presentation neither reads a photo library nor fetches URLs.
    public struct ClaudeMediaViewer: View {
        public var item: ClaudeMedia
        public var controlsVisible: Bool
        public var mediaContent: (ClaudeMedia, ClaudeMediaPresentation) -> AnyView
        public var onAction: (ClaudeMediaAction) -> Void
        public init(
            item: ClaudeMedia, controlsVisible: Bool,
            mediaContent: @escaping (ClaudeMedia, ClaudeMediaPresentation) -> AnyView,
            onAction: @escaping (ClaudeMediaAction) -> Void
        ) {
            self.item = item
            self.controlsVisible = controlsVisible
            self.mediaContent = mediaContent
            self.onAction = onAction
        }
        public var body: some View {
            VStack(spacing: 0) {
                Group {
                    if controlsVisible {
                        HStack {
                            Button {
                                onAction(.close)
                            } label: {
                                Image(systemName: "xmark").font(.system(size: 18)).frame(width: 44, height: 44)
                            }.glassEffect(in: .circle).accessibilityLabel("Close image").accessibilityIdentifier(
                                "media.viewer.close")
                            Spacer(minLength: 8)
                            Text(item.fileName).font(.system(size: 16, weight: .semibold)).lineLimit(1)
                            Spacer(minLength: 8)
                            HStack(spacing: 0) {
                                Button {
                                    onAction(.edit(item))
                                } label: {
                                    Image(systemName: "pencil").frame(width: 48, height: 44)
                                }.accessibilityLabel("Edit image").accessibilityIdentifier("media.viewer.edit")
                                Button {
                                    onAction(.share(item))
                                } label: {
                                    Image(systemName: "square.and.arrow.up").frame(width: 48, height: 44)
                                }.accessibilityLabel("Share image").accessibilityIdentifier("media.viewer.share")
                            }.glassEffect(in: .capsule)
                        }
                    } else {
                        Color.clear.frame(height: 44).accessibilityHidden(true)
                    }
                }.padding(.horizontal, 16).padding(.top, 16)
                GeometryReader { geometry in
                    let width = min(geometry.size.width, geometry.size.height * item.displayAspectRatio)
                    let height = width / item.displayAspectRatio
                    mediaContent(item, .viewer).frame(width: width, height: height).clipped()
                        .contentShape(Rectangle()).onTapGesture { onAction(.toggleControls) }
                        .accessibilityLabel(item.accessibilityDescription).accessibilityAddTraits(.isButton)
                        .accessibilityIdentifier("media.viewer.image")
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }.padding(.bottom, 24)
            }.background(.black).foregroundStyle(.white).preferredColorScheme(.dark).statusBarHidden(false)
        }
    }
    public struct ClaudeVideoFileCard: View {
        public var item: ClaudeMedia
        public init(item: ClaudeMedia) { self.item = item }
        public var body: some View {
            VStack(spacing: 0) {
                Rectangle().fill(Color(white: 0.90)).overlay {
                    Image(systemName: "doc.text").font(.system(size: 20)).foregroundStyle(.gray)
                }.frame(width: 112, height: 88).clipShape(.rect(topLeadingRadius: 4, topTrailingRadius: 4)).padding(
                    .top, 12)
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.fileStem).font(.system(size: 13, weight: .semibold)).lineLimit(1).truncationMode(.middle)
                    Text(item.fileExtension).font(.system(size: 12)).foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 10).frame(height: 40).background(
                    ClaudePalette.panel)
            }.frame(width: 140, height: 140).background(ClaudePalette.codeBackground).clipShape(.rect(cornerRadius: 16))
                .overlay { RoundedRectangle(cornerRadius: 16).stroke(.secondary.opacity(0.2), lineWidth: 0.6) }
        }
    }
    /// The host supplies playback pixels/lifecycle; the package adds no transport controls or looping.
    public struct ClaudeVideoFileViewer: View {
        public var item: ClaudeMedia
        public var mediaContent: (ClaudeMedia, ClaudeMediaPresentation) -> AnyView
        public var onAction: (ClaudeMediaAction) -> Void
        public init(
            item: ClaudeMedia, mediaContent: @escaping (ClaudeMedia, ClaudeMediaPresentation) -> AnyView,
            onAction: @escaping (ClaudeMediaAction) -> Void
        ) {
            self.item = item
            self.mediaContent = mediaContent
            self.onAction = onAction
        }
        public var body: some View {
            GeometryReader { geometry in
                mediaContent(item, .videoViewer).frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped().accessibilityIdentifier("media.video.content")
            }.background(.black).overlay(alignment: .top) {
                HStack(spacing: 12) {
                    Button {
                        onAction(.close)
                    } label: {
                        Image(systemName: "xmark").font(.system(size: 20)).frame(width: 44, height: 44)
                    }.glassEffect(in: .circle).accessibilityLabel("Close video").accessibilityIdentifier(
                        "media.video.close")
                    Text(item.fileName).font(.system(size: 17, weight: .semibold)).lineLimit(1).frame(
                        maxWidth: .infinity)
                    Menu {
                        Button("Download", systemImage: "arrow.down.to.line") { onAction(.download(item)) }
                    } label: {
                        Image(systemName: "ellipsis").frame(width: 44, height: 44)
                    }.glassEffect(in: .circle).accessibilityLabel("Video file options").accessibilityIdentifier(
                        "media.video.options")
                }.padding(16).background(.ultraThinMaterial)
            }.tint(ClaudePalette.ink).foregroundStyle(ClaudePalette.ink).presentationDetents([.large])
                .presentationCornerRadius(40).presentationDragIndicator(.hidden)
                .onAppear { onAction(.videoViewerAppeared(item)) }.onDisappear {
                    onAction(.videoViewerDisappeared(item))
                }
        }
    }
#endif
