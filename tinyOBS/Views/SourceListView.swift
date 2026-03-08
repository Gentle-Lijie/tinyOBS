import SwiftUI

struct SourceListView: View {
    let sources: [VideoSource]
    @Binding var selectedSource: VideoSource
    let onSelect: (VideoSource) -> Void
    let onRefresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("视频源")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: onRefresh) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12))
                        Text("刷新")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .help("刷新可用设备列表")
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(sources) { source in
                        SourceCard(
                            source: source,
                            isSelected: selectedSource.id == source.id,
                            onTap: {
                                onSelect(source)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct SourceCard: View {
    let source: VideoSource
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: source.type.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .primary)

                Text(source.name)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 100, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SourceListView(
        sources: [
            .none,
            VideoSource(screen: "主显示器")
        ],
        selectedSource: .constant(.none),
        onSelect: { _ in },
        onRefresh: {}
    )
    .frame(height: 120)
}
