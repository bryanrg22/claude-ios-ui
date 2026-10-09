#if canImport(UIKit)
    import SwiftUI

    /// An offline camera presentation. Supply your own preview view and consume capture metadata.
    /// This UI never requests camera/microphone access. Only the idle photo layout is reference-observed.
    public struct ClaudeCameraView<Preview: View>: View {
        @State private var state = CameraState()
        private let preview: Preview
        private let onCancel: () -> Void
        private let onCapture: (CameraCapture) -> Void
        public init(
            onCancel: @escaping () -> Void, onCapture: @escaping (CameraCapture) -> Void,
            @ViewBuilder preview: () -> Preview
        ) {
            self.onCancel = onCancel
            self.onCapture = onCapture
            self.preview = preview()
        }
        public var body: some View {
            GeometryReader { geometry in
                let size = geometry.size
                let previewHeight = min(size.width * 4 / 3, size.height * 0.615)
                let previewTop = size.height * (118 / 852)
                ZStack {
                    Color.black
                    preview
                        .frame(width: size.width, height: previewHeight)
                        .scaleEffect(state.zoom)
                        .scaleEffect(x: state.frontFacing ? -1 : 1, y: 1)
                        .frame(width: size.width, height: previewHeight).clipped()
                        .overlay(alignment: .bottom) { zoomPicker.padding(.bottom, 17) }
                        .position(x: size.width / 2, y: previewTop + previewHeight / 2)
                    Button {
                        state.reduce(.cycleFlash)
                    } label: {
                        ZStack(alignment: .bottomTrailing) {
                            Image(systemName: state.flash == .off ? "bolt.slash.fill" : "bolt.fill").font(
                                .system(size: 23))
                            if state.flash == .auto {
                                Text("A").font(.system(size: 9, weight: .bold)).foregroundStyle(.black).frame(
                                    width: 12, height: 12
                                ).background(.white, in: .circle).offset(x: 6, y: 2)
                            }
                        }.foregroundStyle(state.flash == .on ? Color.yellow : .white).frame(width: 44, height: 44)
                    }.accessibilityLabel("Flash").accessibilityValue(state.flash.rawValue).accessibilityIdentifier(
                        "camera.flash"
                    )
                    .position(x: size.width / 2, y: size.height * (80 / 852))
                    Button {
                        if let capture = state.reduce(.shutter) { onCapture(capture) }
                    } label: {
                        ZStack {
                            Circle().fill(.white.opacity(0.13)).overlay {
                                Circle().stroke(.white.opacity(0.25), lineWidth: 0.7)
                            }
                            if state.recording {
                                RoundedRectangle(cornerRadius: 6).fill(.red).frame(width: 30, height: 30)
                            } else {
                                Circle().fill(state.mode == .photo ? .white : .red).padding(6)
                            }
                        }.frame(width: 80, height: 80)
                    }.accessibilityLabel(
                        state.recording ? "Stop video" : state.mode == .photo ? "Take photo" : "Record video"
                    ).accessibilityIdentifier("camera.shutter")
                        .position(x: size.width / 2, y: size.height * (698 / 852))
                    GlassEffectContainer(spacing: 18) {
                        HStack(spacing: 0) {
                            Button {
                                state.reduce(.cancel)
                                onCancel()
                            } label: {
                                Image(systemName: "xmark").font(.system(size: 25, weight: .light)).frame(
                                    width: 48, height: 48)
                            }.glassEffect(in: .circle).accessibilityLabel("Cancel camera").accessibilityIdentifier(
                                "camera.cancel")
                            Spacer(minLength: 8)
                            HStack(spacing: 0) {
                                ForEach(CameraMode.allCases, id: \.self) { mode in
                                    Button {
                                        state.reduce(.selectMode(mode))
                                    } label: {
                                        Text(mode.rawValue).font(.system(size: 17, weight: .regular)).tracking(0.7)
                                            .foregroundStyle(state.mode == mode ? .yellow : .white).frame(
                                                width: 88, height: 42
                                            )
                                            .glassEffect(state.mode == mode ? .regular : .identity, in: .capsule)
                                    }.disabled(state.recording).accessibilityIdentifier("camera.mode.\(mode.rawValue)")
                                        .accessibilityAddTraits(state.mode == mode ? [.isSelected] : [])
                                }
                            }.padding(3).background(Color(white: 0.065), in: .capsule)
                            Spacer(minLength: 8)
                            Button {
                                state.reduce(.flip)
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath").font(.system(size: 24, weight: .light))
                                    .frame(width: 48, height: 48)
                            }.glassEffect(in: .circle).disabled(state.recording).accessibilityLabel("Flip camera")
                                .accessibilityValue(state.frontFacing ? "Front" : "Back").accessibilityIdentifier(
                                    "camera.flip")
                        }.padding(.horizontal, 34)
                    }.position(x: size.width / 2, y: size.height * (795 / 852))
                }
            }.ignoresSafeArea().preferredColorScheme(.dark).foregroundStyle(.white).statusBarHidden()
        }
        private var zoomPicker: some View {
            HStack(spacing: 0) {
                ForEach([0.5, 1, 2], id: \.self) { zoom in
                    Button {
                        state.reduce(.selectZoom(zoom))
                    } label: {
                        Text(zoom == 0.5 ? ".5" : state.zoom == zoom ? "\(Int(zoom))×" : "\(Int(zoom))")
                            .font(.system(size: 17)).foregroundStyle(state.zoom == zoom ? .yellow : .white)
                            .frame(width: 39, height: 39).background(
                                state.zoom == zoom ? Color.black.opacity(0.48) : .clear, in: .circle)
                    }.accessibilityLabel("\(zoom) times zoom").accessibilityIdentifier("camera.zoom.\(zoom)")
                        .accessibilityAddTraits(state.zoom == zoom ? [.isSelected] : [])
                }
            }
        }
    }
    struct SyntheticCameraPreview: View {
        var body: some View {
            GeometryReader { geometry in
                let size = geometry.size
                ZStack {
                    LinearGradient(
                        colors: [Color(red: 0.64, green: 0.68, blue: 0.62), Color(red: 0.32, green: 0.43, blue: 0.37)],
                        startPoint: .topLeading, endPoint: .bottomTrailing)
                    Path { p in
                        for index in 1...4 {
                            let y = size.height * Double(index) / 5
                            p.move(to: CGPoint(x: 0, y: y))
                            p.addLine(to: CGPoint(x: size.width, y: y + 25))
                        }
                        p.move(to: CGPoint(x: size.width * 0.72, y: 0))
                        p.addLine(to: CGPoint(x: size.width * 0.9, y: size.height))
                    }.stroke(Color.black.opacity(0.12), lineWidth: 1)
                    RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.83, green: 0.72, blue: 0.48)).frame(
                        width: size.width * 0.46, height: size.height * 0.4
                    ).rotationEffect(.degrees(-12)).shadow(color: .black.opacity(0.2), radius: 8, x: 4, y: 8)
                    Text("OFFLINE PREVIEW").font(.system(size: 10, weight: .semibold)).tracking(2).foregroundStyle(
                        .white.opacity(0.8)
                    ).position(x: size.width / 2, y: 18)
                }
            }
        }
    }
#endif
