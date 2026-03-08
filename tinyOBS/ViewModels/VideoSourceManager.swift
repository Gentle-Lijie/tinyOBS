import Foundation
import AVFoundation
import Combine

class VideoSourceManager: ObservableObject {
    // MARK: - Published Properties
    @Published var availableSources: [VideoSource] = [.none]
    @Published var selectedSource: VideoSource = .none
    @Published var activeSession: AVCaptureSession?
    @Published var errorMessage: String?

    // MARK: - Services
    let screenCaptureService = ScreenCaptureService()
    private var captureSession: AVCaptureSession?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init() {
        setupNotifications()
    }

    // MARK: - Public Methods

    /// 枚举所有可用的视频设备
    func enumerateDevices() {
        var sources: [VideoSource] = [.none]

        // 构建设备类型列表 - macOS 只支持这些类型
        var deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera
        ]

        // .external 只在 macOS 14+ 可用
        if #available(macOS 14.0, *) {
            deviceTypes.append(.external)
        }

        // 获取所有视频输入设备
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: .unspecified
        )

        for device in discoverySession.devices {
            let source = VideoSource(device: device)
            sources.append(source)
        }

        // 添加屏幕录制源
        sources.append(VideoSource(screen: "主显示器"))

        if Thread.isMainThread {
            self.availableSources = sources
        } else {
            DispatchQueue.main.async {
                self.availableSources = sources
            }
        }
    }

    /// 切换到指定的视频源
    func switchToSource(_ source: VideoSource) {
        // 停止当前会话
        stopCurrentSession()

        // 如果选择的是"无"，直接返回
        guard source.type != .none else {
            selectedSource = .none
            activeSession = nil
            return
        }

        // 如果选择的是屏幕录制
        if source.type == .screen {
            Task {
                do {
                    try await screenCaptureService.startCapture()
                    await MainActor.run {
                        selectedSource = source
                        activeSession = nil
                    }
                } catch {
                    await MainActor.run {
                        self.errorMessage = "无法启动屏幕录制: \(error.localizedDescription)"
                    }
                }
            }
            return
        }

        // 如果选择的是摄像头或采集卡
        guard let device = source.device else { return }

        Task {
            do {
                let session = try await createCaptureSession(for: device)
                await MainActor.run {
                    self.captureSession = session
                    self.activeSession = session
                    self.selectedSource = source
                    session.startRunning()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "无法启动视频设备: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Private Methods

    private func createCaptureSession(for device: AVCaptureDevice) async throws -> AVCaptureSession {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        // 添加视频输入
        let input = try AVCaptureDeviceInput(device: device)
        if session.canAddInput(input) {
            session.addInput(input)
        }

        // 添加音频输入（如果可用）
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            if session.canAddInput(audioInput) {
                session.addInput(audioInput)
            }
        }

        return session
    }

    private func stopCurrentSession() {
        screenCaptureService.stopCapture()
        captureSession?.stopRunning()
        captureSession = nil
    }

    private func setupNotifications() {
        // 监听设备连接/断开
        NotificationCenter.default
            .publisher(for: .AVCaptureDeviceWasConnected)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.enumerateDevices()
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: .AVCaptureDeviceWasDisconnected)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.enumerateDevices()
            }
            .store(in: &cancellables)
    }
}

