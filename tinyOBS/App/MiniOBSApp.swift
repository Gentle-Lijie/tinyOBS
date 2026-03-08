import SwiftUI

@main
struct tinyOBSApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var currentSource: VideoSourceType = .none
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
}
