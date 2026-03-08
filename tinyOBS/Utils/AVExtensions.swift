import Foundation
import AVFoundation

// MARK: - AVCaptureDevice Extensions
extension AVCaptureDevice {
    /// 检查设备是否为外部设备（如采集卡）
    var isExternal: Bool {
        return !isConnected || modelID.contains("External")
    }

    /// 获取设备的友好名称
    var friendlyName: String {
        if localizedName.contains("Capture") || localizedName.contains("采集") {
            return "采集卡 (\(localizedName))"
        }
        return localizedName
    }
}

// MARK: - AVCaptureSession Extensions
extension AVCaptureSession {
    /// 获取当前的输入设备
    var currentInputDevices: [AVCaptureDevice] {
        return inputs.compactMap { input in
            (input as? AVCaptureDeviceInput)?.device
        }
    }

    /// 检查是否有视频输入
    var hasVideoInput: Bool {
        return inputs.contains { input in
            (input as? AVCaptureDeviceInput)?.device.hasMediaType(.video) ?? false
        }
    }

    /// 检查是否有音频输入
    var hasAudioInput: Bool {
        return inputs.contains { input in
            (input as? AVCaptureDeviceInput)?.device.hasMediaType(.audio) ?? false
        }
    }
}

// MARK: - CMTime Extensions
extension CMTime {
    /// 转换为 TimeInterval
    var timeInterval: TimeInterval {
        return CMTimeGetSeconds(self)
    }

    /// 从 TimeInterval 创建
    static func fromTimeInterval(_ interval: TimeInterval) -> CMTime {
        return CMTime(seconds: interval, preferredTimescale: 600)
    }
}

// MARK: - CMSampleBuffer Extensions
extension CMSampleBuffer {
    /// 获取展示时间戳
    var presentationTimestamp: CMTime {
        return CMSampleBufferGetPresentationTimeStamp(self)
    }

    /// 获取持续时间
    var duration: CMTime {
        return CMSampleBufferGetDuration(self)
    }

    /// 检查是否为关键帧
    var isKeyFrame: Bool {
        guard let attachments = CMSampleBufferGetSampleAttachmentsArray(self, createIfNecessary: false) as? [[CFString: Any]],
              let firstAttachment = attachments.first else {
            return false
        }
        return (firstAttachment[kCMSampleAttachmentKey_DependsOnOthers] as? Bool) != true
    }
}
