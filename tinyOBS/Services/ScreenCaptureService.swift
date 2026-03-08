import Foundation
import ScreenCaptureKit
import AVFoundation

class ScreenCaptureService: ObservableObject {
    // MARK: - Properties
    @Published var isCapturing = false
    @Published var previewImage: CGImage?

    private var stream: SCStream?
    private let videoSampleBufferQueue = DispatchQueue(label: "com.miniobs.screenCapture.video")
    private var sampleBufferHandler: ((CMSampleBuffer) -> Void)?

    // MARK: - Public Methods

    func startCapture() async throws {
        // 获取可共享内容
        let content = try await SCShareableContent.excludingDesktopWindows(
            false,
            onScreenWindowsOnly: true
        )

        guard let display = content.displays.first else {
            throw ScreenCaptureError.noDisplayAvailable
        }

        // 创建筛选器
        let filter = SCContentFilter(display: display, excludingWindows: [])

        // 配置
        let configuration = SCStreamConfiguration()
        configuration.width = display.width
        configuration.height = display.height
        configuration.minimumFrameInterval = CMTime(value: 1, timescale: 60)
        configuration.pixelFormat = kCVPixelFormatType_32BGRA
        configuration.capturesAudio = true

        // 创建流
        stream = SCStream(
            filter: filter,
            configuration: configuration,
            delegate: StreamDelegate()
        )

        // 添加视频输出
        try stream?.addStreamOutput(
            VideoStreamOutput(service: self),
            type: .screen,
            sampleHandlerQueue: videoSampleBufferQueue
        )

        // 添加音频输出
        try stream?.addStreamOutput(
            AudioStreamOutput(service: self),
            type: .audio,
            sampleHandlerQueue: videoSampleBufferQueue
        )

        // 开始捕获
        try await stream?.startCapture()

        await MainActor.run {
            self.isCapturing = true
        }
    }

    func stopCapture() {
        stream?.stopCapture()
        stream = nil
        isCapturing = false
        previewImage = nil
    }

    func setSampleBufferHandler(_ handler: @escaping (CMSampleBuffer) -> Void) {
        self.sampleBufferHandler = handler
    }

    // MARK: - Internal Methods

    func processVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        // 更新预览图
        if let imageBuffer = sampleBuffer.imageBuffer {
            let ciImage = CIImage(cvImageBuffer: imageBuffer)
            let context = CIContext()
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                DispatchQueue.main.async {
                    self.previewImage = cgImage
                }
            }
        }

        // 传递给录制器
        sampleBufferHandler?(sampleBuffer)
    }

    func processAudioSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        // 传递给录制器
        sampleBufferHandler?(sampleBuffer)
    }
}

// MARK: - Stream Delegate
private class StreamDelegate: NSObject, SCStreamDelegate {
    func stream(_ stream: SCStream, didStopWithError error: Error) {
        print("Stream stopped with error: \(error)")
    }
}

// MARK: - Video Stream Output
private class VideoStreamOutput: NSObject, SCStreamOutput {
    weak var service: ScreenCaptureService?

    init(service: ScreenCaptureService) {
        self.service = service
    }

    func didOutput(sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        service?.processVideoSampleBuffer(sampleBuffer)
    }
}

// MARK: - Audio Stream Output
private class AudioStreamOutput: NSObject, SCStreamOutput {
    weak var service: ScreenCaptureService?

    init(service: ScreenCaptureService) {
        self.service = service
    }

    func didOutput(sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        service?.processAudioSampleBuffer(sampleBuffer)
    }
}

// MARK: - Errors
enum ScreenCaptureError: LocalizedError {
    case noDisplayAvailable
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .noDisplayAvailable:
            return "没有可用的显示器"
        case .permissionDenied:
            return "屏幕录制权限被拒绝"
        }
    }
}
