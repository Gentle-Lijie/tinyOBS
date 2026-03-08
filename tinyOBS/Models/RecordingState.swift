import Foundation

enum RecordingState: Equatable {
    case idle
    case preparing
    case recording
    case paused
    case finishing
    case error(String)

    var isRecording: Bool {
        self == .recording || self == .preparing
    }

    var canStart: Bool {
        self == .idle || self == .error("")
    }

    var canStop: Bool {
        self == .recording || self == .paused
    }
}

struct RecordingInfo {
    let fileURL: URL
    let startTime: Date
    var duration: TimeInterval
    var fileSize: Int64?

    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    var formattedFileSize: String {
        guard let size = fileSize else { return "未知" }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}
