import Foundation
import AVFoundation

class VideoWriter {
    // MARK: - Properties
    private let assetWriter: AVAssetWriter
    private var videoInput: AVAssetWriterInput?
    private var audioInput: AVAssetWriterInput?

    private let writerQueue = DispatchQueue(label: "com.miniobs.videowriter")
    private var isWriting = false

    private let quality: SettingsStore.VideoQuality
    private let frameRate: Int

    // MARK: - Initialization
    init(outputURL: URL, quality: SettingsStore.VideoQuality = .medium, frameRate: Int = 30) {
        self.quality = quality
        self.frameRate = frameRate

        do {
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        } catch {
            fatalError("Failed to create asset writer: \(error)")
        }
    }

    // MARK: - Public Methods

    func startWriting() {
        writerQueue.async { [weak self] in
            guard let self = self else { return }

            self.assetWriter.startWriting()
            self.assetWriter.startSession(atSourceTime: .zero)
            self.isWriting = true
        }
    }

    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        writerQueue.async { [weak self] in
            guard let self = self, self.isWriting else { return }

            let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)

            if CMSampleBufferGetNumSamples(sampleBuffer) > 0 {
                if let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
                    let mediaType = CMFormatDescriptionGetMediaType(formatDescription)

                    if mediaType == kCMMediaType_Video {
                        self.processVideoSample(sampleBuffer, at: presentationTime)
                    } else if mediaType == kCMMediaType_Audio {
                        self.processAudioSample(sampleBuffer, at: presentationTime)
                    }
                }
            }
        }
    }

    func finishWriting(completion: @escaping () -> Void) {
        writerQueue.async { [weak self] in
            guard let self = self else {
                completion()
                return
            }

            self.isWriting = false

            self.videoInput?.markAsFinished()
            self.audioInput?.markAsFinished()

            self.assetWriter.finishWriting {
                completion()
            }
        }
    }

    // MARK: - Private Methods

    private func processVideoSample(_ sampleBuffer: CMSampleBuffer, at time: CMTime) {
        // 初始化视频输入（如果需要）
        if videoInput == nil {
            setupVideoInput(for: sampleBuffer)
        }

        // 写入视频样本
        if let input = videoInput, input.isReadyForMoreMediaData {
            input.append(sampleBuffer)
        }
    }

    private func processAudioSample(_ sampleBuffer: CMSampleBuffer, at time: CMTime) {
        // 初始化音频输入（如果需要）
        if audioInput == nil {
            setupAudioInput(for: sampleBuffer)
        }

        // 写入音频样本
        if let input = audioInput, input.isReadyForMoreMediaData {
            input.append(sampleBuffer)
        }
    }

    private func setupVideoInput(for sampleBuffer: CMSampleBuffer) {
        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else {
            return
        }

        let sourceDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
        let targetDimensions = quality.resolution

        // 计算保持宽高比的尺寸
        let aspectRatio = CGFloat(sourceDimensions.width) / CGFloat(sourceDimensions.height)
        var width = targetDimensions.width
        var height = targetDimensions.height

        if CGFloat(sourceDimensions.width) > CGFloat(sourceDimensions.height) {
            height = width / aspectRatio
        } else {
            width = height * aspectRatio
        }

        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(width),
            AVVideoHeightKey: Int(height),
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: quality.bitRate,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
                AVVideoExpectedSourceFrameRateKey: frameRate,
                AVVideoMaxKeyFrameIntervalKey: frameRate * 2
            ]
        ]

        let input = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        input.expectsMediaDataInRealTime = true

        if assetWriter.canAdd(input) {
            assetWriter.add(input)
            videoInput = input
        }
    }

    private func setupAudioInput(for sampleBuffer: CMSampleBuffer) {
        let audioSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0,
            AVEncoderBitRateKey: 128_000
        ]

        let input = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        input.expectsMediaDataInRealTime = true

        if assetWriter.canAdd(input) {
            assetWriter.add(input)
            audioInput = input
        }
    }
}
