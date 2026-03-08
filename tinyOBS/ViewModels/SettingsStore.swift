import Foundation
import SwiftUI

class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    // MARK: - Settings
    @Published var outputDirectory: URL {
        didSet {
            UserDefaults.standard.set(outputDirectory.path, forKey: "outputDirectory")
        }
    }

    @Published var videoQuality: VideoQuality {
        didSet {
            UserDefaults.standard.set(videoQuality.rawValue, forKey: "videoQuality")
        }
    }

    @Published var frameRate: Int {
        didSet {
            UserDefaults.standard.set(frameRate, forKey: "frameRate")
        }
    }

    @Published var recordAudio: Bool {
        didSet {
            UserDefaults.standard.set(recordAudio, forKey: "recordAudio")
        }
    }

    // MARK: - Types
    enum VideoQuality: String, CaseIterable, Identifiable {
        case low = "低 (720p)"
        case medium = "中 (1080p)"
        case high = "高 (4K)"

        var id: String { rawValue }

        var resolution: CGSize {
            switch self {
            case .low: return CGSize(width: 1280, height: 720)
            case .medium: return CGSize(width: 1920, height: 1080)
            case .high: return CGSize(width: 3840, height: 2160)
            }
        }

        var bitRate: Int {
            switch self {
            case .low: return 2_000_000
            case .medium: return 5_000_000
            case .high: return 15_000_000
            }
        }
    }

    // MARK: - Initialization
    private init() {
        // 先初始化所有属性
        let savedPath = UserDefaults.standard.string(forKey: "outputDirectory")
        self.outputDirectory = savedPath != nil
            ? URL(fileURLWithPath: savedPath!)
            : FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        self.videoQuality = VideoQuality(
            rawValue: UserDefaults.standard.string(forKey: "videoQuality") ?? ""
        ) ?? .medium

        let savedFrameRate = UserDefaults.standard.integer(forKey: "frameRate")
        self.frameRate = savedFrameRate > 0 ? savedFrameRate : 30

        // 检查是否已经设置过 recordAudio
        let hasRecordAudioKey = UserDefaults.standard.object(forKey: "recordAudio") != nil
        self.recordAudio = hasRecordAudioKey
            ? UserDefaults.standard.bool(forKey: "recordAudio")
            : true  // 默认开启音频
    }
}
