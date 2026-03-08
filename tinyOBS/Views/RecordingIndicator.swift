import SwiftUI

struct RecordingIndicator: View {
    @Binding var duration: TimeInterval
    @State private var isBlinking = true

    var body: some View {
        HStack(spacing: 8) {
            // 红色闪烁圆点
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .opacity(isBlinking ? 1.0 : 0.3)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                        isBlinking.toggle()
                    }
                }

            // 录制时间
            Text(formattedDuration)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.7))
        )
    }

    private var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    ZStack {
        Color.gray
        RecordingIndicator(duration: .constant(125))
    }
    .frame(width: 200, height: 100)
}
