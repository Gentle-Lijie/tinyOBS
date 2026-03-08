import SwiftUI

struct ControlBarView: View {
    @Binding var isRecording: Bool
    let onStartRecording: () -> Void
    let onStopRecording: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // 录制按钮
            if isRecording {
                Button(action: onStopRecording) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("停止录制")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: onStartRecording) {
                    HStack(spacing: 8) {
                        Image(systemName: "record.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                        Text("开始录制")
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            // 设置按钮
            Button(action: onOpenSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("设置")
        }
    }
}

#Preview("未录制") {
    ControlBarView(
        isRecording: .constant(false),
        onStartRecording: {},
        onStopRecording: {},
        onOpenSettings: {}
    )
}

#Preview("录制中") {
    ControlBarView(
        isRecording: .constant(true),
        onStartRecording: {},
        onStopRecording: {},
        onOpenSettings: {}
    )
}
