import Foundation
import AVFoundation
import Combine

class RecordingManager: ObservableObject {
    // MARK: - Published Properties
    @Published var state: RecordingState = .idle
    @Published var recordingDuration: TimeInterval = 0
    @Published var currentRecording: RecordingInfo?

    // MARK: - Private Properties
    private var videoWriter: VideoWriter?
    private var timer: Timer?
    private var startTime: Date?
    private let settings = SettingsStore.shared

    // MARK: - Public Methods

    func startRecording(
        session: AVCaptureSession?,
        screenCapture: ScreenCaptureService?,
        sourceType: VideoSourceType
    ) {
        guard state.canStart else { return }

        state = .preparing

        // 生成输出文件路径
        let outputURL = generateOutputURL()
        currentRecording = RecordingInfo(
            fileURL: outputURL,
            startTime: Date(),
            duration: 0,
            fileSize: nil
        )

        // 根据视频源类型创建录制器
        if let screenCapture = screenCapture, sourceType == .screen {
            startScreenRecording(screenCapture: screenCapture, outputURL: outputURL)
        } else if let session = session {
            startDeviceRecording(session: session, outputURL: outputURL)
        } else {
            state = .error("没有可用的视频源")
            return
        }

        startTime = Date()
        startTimer()
        state = .recording
    }

    func stopRecording() {
        guard state.canStop else { return }

        state = .finishing
        stopTimer()

        videoWriter?.finishWriting { [weak self] in
            DispatchQueue.main.async {
                self?.state = .idle
                self?.videoWriter = nil
            }
        }
    }

    // MARK: - Private Methods

    private func startDeviceRecording(session: AVCaptureSession, outputURL: URL) {
        videoWriter = VideoWriter(
            outputURL: outputURL,
            quality: settings.videoQuality,
            frameRate: settings.frameRate
        )
        videoWriter?.startWriting()

        // 添加输出到 session
        // 注意：实际实现需要更复杂的视频数据处理
    }

    private func startScreenRecording(screenCapture: ScreenCaptureService, outputURL: URL) {
        videoWriter = VideoWriter(
            outputURL: outputURL,
            quality: settings.videoQuality,
            frameRate: settings.frameRate
        )
        videoWriter?.startWriting()

        // 设置屏幕录制回调
        screenCapture.setSampleBufferHandler { [weak self] sampleBuffer in
            self?.videoWriter?.processSampleBuffer(sampleBuffer)
        }
    }

    private func generateOutputURL() -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = dateFormatter.string(from: Date())

        return settings.outputDirectory
            .appendingPathComponent("tinyOBS_Recording_\(dateString).mp4")
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.recordingDuration = Date().timeIntervalSince(startTime)

            // 更新录制信息
            if var recording = self.currentRecording {
                recording.duration = self.recordingDuration
                self.currentRecording = recording
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
