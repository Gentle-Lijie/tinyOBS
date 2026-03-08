import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var sourceManager = VideoSourceManager()
    @StateObject private var recordingManager = RecordingManager()
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // 预览区域
            PreviewView(
                captureSession: sourceManager.activeSession,
                screenCapture: sourceManager.screenCaptureService
            )
            .overlay(alignment: .topLeading) {
                if appState.isRecording {
                    RecordingIndicator(duration: $recordingManager.recordingDuration)
                        .padding(16)
                }
            }

            Divider()

            // 视频源选择
            SourceListView(
                sources: sourceManager.availableSources,
                selectedSource: $sourceManager.selectedSource,
                onSelect: { source in
                    sourceManager.switchToSource(source)
                    appState.currentSource = source.type
                },
                onRefresh: {
                    sourceManager.enumerateDevices()
                }
            )
            .padding(.vertical, 12)

            Divider()

            // 控制栏
            ControlBarView(
                isRecording: $appState.isRecording,
                onStartRecording: {
                    startRecording()
                },
                onStopRecording: {
                    stopRecording()
                },
                onOpenSettings: {
                    showSettings = true
                }
            )
            .padding(16)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            sourceManager.enumerateDevices()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private func startRecording() {
        let session = sourceManager.activeSession
        let screenCapture = sourceManager.screenCaptureService

        recordingManager.startRecording(
            session: session,
            screenCapture: screenCapture,
            sourceType: sourceManager.selectedSource.type
        )
        appState.isRecording = true
    }

    private func stopRecording() {
        recordingManager.stopRecording()
        appState.isRecording = false
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
