import SwiftUI
import AVFoundation

/// Silent generated sample only. Real media resolution/playback belongs to the embedding app.
struct DemoVideo: UIViewRepresentable {
    func makeUIView(context: Context) -> DemoVideoSurface {
        let view = DemoVideoSurface()
        guard let url = Bundle.main.url(forResource: "Garden-Motion", withExtension: "mp4") else { return view }
        let player = AVPlayer(url: url)
        player.isMuted = true
        player.actionAtItemEnd = .pause
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspect
        view.isAccessibilityElement = true
        view.accessibilityLabel = "Synthetic garden motion"
        view.accessibilityValue = "Playing"
        context.coordinator.observer = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main
        ) { [weak view] _ in
            MainActor.assumeIsolated { view?.accessibilityValue = "Ended" }
        }
        player.play()
        return view
    }
    func updateUIView(_ view: DemoVideoSurface, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator() }
    static func dismantleUIView(_ view: DemoVideoSurface, coordinator: Coordinator) {
        view.playerLayer.player?.pause()
        view.playerLayer.player = nil
        if let observer = coordinator.observer { NotificationCenter.default.removeObserver(observer) }
    }
    final class Coordinator { var observer: NSObjectProtocol? }
}
final class DemoVideoSurface: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}
