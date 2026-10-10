import Foundation

public enum CameraMode: String, CaseIterable, Sendable { case video = "VIDEO", photo = "PHOTO" }
public enum CameraFlash: String, CaseIterable, Sendable { case auto, on, off }
public struct CameraCapture: Equatable, Sendable {
    public let mode: CameraMode
    public let zoom: Double
    public let frontFacing: Bool
    public init(mode: CameraMode, zoom: Double, frontFacing: Bool) {
        self.mode = mode
        self.zoom = zoom
        self.frontFacing = frontFacing
    }
}
@nonexhaustive public enum CameraAction: Equatable, Sendable {
    case selectMode(CameraMode), selectZoom(Double), cycleFlash, flip, shutter, cancel
}
/// Offline presentation state only. No camera or microphone access is performed.
public struct CameraState: Equatable, Sendable {
    public private(set) var mode: CameraMode = .photo
    public private(set) var flash: CameraFlash = .auto
    public private(set) var zoom: Double = 1
    public private(set) var frontFacing = false
    public private(set) var recording = false
    public init() {}
    /// A photo click or completed simulated video emits metadata for the host.
    @discardableResult public mutating func reduce(_ action: CameraAction) -> CameraCapture? {
        switch action {
        case .selectMode(let mode):
            guard !recording else { return nil }
            self.mode = mode
        case .selectZoom(let zoom):
            guard [0.5, 1, 2].contains(zoom) else { return nil }
            self.zoom = zoom
        case .cycleFlash: flash = flash == .auto ? .on : flash == .on ? .off : .auto
        case .flip:
            guard !recording else { return nil }
            frontFacing.toggle()
        case .shutter:
            if mode == .video, !recording {
                recording = true
                return nil
            }
            recording = false
            return CameraCapture(mode: mode, zoom: zoom, frontFacing: frontFacing)
        case .cancel: recording = false
        }
        return nil
    }
}
