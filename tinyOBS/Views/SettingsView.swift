import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsStore.shared
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标题
            HStack {
                Text("设置")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            Divider()

            // 输出目录
            VStack(alignment: .leading, spacing: 8) {
                Text("录制保存位置")
                    .font(.headline)

                HStack {
                    Text(settings.outputDirectory.path)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()

                    Button("选择...") {
                        openDirectoryPicker()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(6)
            }

            // 视频质量
            VStack(alignment: .leading, spacing: 8) {
                Text("视频质量")
                    .font(.headline)

                Picker("", selection: $settings.videoQuality) {
                    ForEach(SettingsStore.VideoQuality.allCases) { quality in
                        Text(quality.rawValue).tag(quality)
                    }
                }
                .pickerStyle(.segmented)
            }

            // 帧率
            VStack(alignment: .leading, spacing: 8) {
                Text("帧率: \(settings.frameRate) FPS")
                    .font(.headline)

                Slider(value: Binding(
                    get: { Double(settings.frameRate) },
                    set: { settings.frameRate = Int($0) }
                ), in: 15...60, step: 5)
            }

            // 音频录制
            VStack(alignment: .leading, spacing: 8) {
                Text("音频")
                    .font(.headline)

                Toggle("录制音频", isOn: $settings.recordAudio)
            }

            Spacer()

            // 底部按钮
            HStack {
                Button("打开录制目录") {
                    NSWorkspace.shared.open(settings.outputDirectory)
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("完成") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 480, height: 400)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private func openDirectoryPicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "选择录制文件的保存目录"

        if panel.runModal() == .OK, let url = panel.url {
            settings.outputDirectory = url
        }
    }
}

#Preview {
    SettingsView()
}
