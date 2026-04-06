import SwiftUI
import SwiftData

struct StyleView: View {
    @Query private var folders: [StyleFolder]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(folders.sorted(by: { $0.createdAt < $1.createdAt })) { folder in
                        NavigationLink {
                            StyleFolderDetailView(folder: folder)
                        } label: {
                            StyleFolderCard(folder: folder)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("내 스타일")
        }
    }
}

struct StyleFolderCard: View {
    let folder: StyleFolder

    var body: some View {
        HStack(spacing: 16) {
            // 미리보기 이미지 (최근 3장)
            ZStack {
                if folder.profiles.isEmpty {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 100, height: 100)
                    Image(systemName: "photo.on.rectangle")
                        .foregroundStyle(.tertiary)
                } else {
                    let previews = Array(folder.profiles.prefix(3))
                    ForEach(Array(previews.enumerated()), id: \.offset) { index, profile in
                        if let uiImage = UIImage(data: profile.imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(12)
                                .offset(x: CGFloat(index * 4), y: CGFloat(index * -4))
                        }
                    }
                }
            }
            .frame(width: 112, height: 112)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(folder.emoji)
                    Text(folder.name)
                        .font(.headline)
                }

                Text("\(folder.profiles.count)장")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if folder.hasAnalysis {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(folder.analysisKeywords.prefix(3), id: \.self) { kw in
                                Text(kw)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.12))
                                    .foregroundStyle(Color.accentColor)
                                    .cornerRadius(10)
                            }
                        }
                    }
                } else {
                    Text(folder.profiles.isEmpty ? "사진을 추가해보세요" : "분석 전")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
                .font(.caption)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}
