import Foundation
import AVFoundation

// MARK: - Video Source Type
enum VideoSourceType: String, CaseIterable, Identifiable {
    case none = "无"
    case captureCard = "采集卡"
    case camera = "摄像头"
    case screen = "屏幕"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .none: return "slash.circle"
        case .captureCard: return "video.badge.plus"
        case .camera: return "video.fill"
        case .screen: return "desktopcomputer"
        }
    }
}

// MARK: - Video Source Model
struct VideoSource: Identifiable, Hashable {
    let id: String
    let name: String
    let type: VideoSourceType
    let device: AVCaptureDevice?

    init(device: AVCaptureDevice) {
        self.id = device.uniqueID
        self.name = device.localizedName
        self.device = device

        // 根据设备类型判断是采集卡还是摄像头
        if device.modelID.contains("Capture") || device.localizedName.contains("采集") {
            self.type = .captureCard
        } else {
            self.type = .camera
        }
    }

    init(screen: String) {
        self.id = "screen_\(screen)"
        self.name = screen
        self.type = .screen
        self.device = nil
    }

    // 用于无视频源
    static let none = VideoSource(
        id: "none",
        name: "无视频源",
        type: .none,
        device: nil
    )

    private init(id: String, name: String, type: VideoSourceType, device: AVCaptureDevice?) {
        self.id = id
        self.name = name
        self.type = type
        self.device = device
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: VideoSource, rhs: VideoSource) -> Bool {
        lhs.id == rhs.id
    }
}
