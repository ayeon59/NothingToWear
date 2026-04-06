import SwiftUI
import SwiftData
import PhotosUI

struct StyleFolderDetailView: View {
    @Bindable var folder: StyleFolder
    @Environment(\.modelContext) private var modelContext

    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var isAnalyzing = false
    @State private var errorMessage: String?

    private let claudeService = ClaudeService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                photoGridSection
                if folder.hasAnalysis {
                    analysisSection
                }
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("\(folder.emoji) \(folder.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: 20,
                    matching: .images
                ) {
                    Image(systemName: "plus")
                }
            }
        }
        .onChange(of: selectedPhotos) { _, newItems in
            Task { await addPhotos(newItems) }
        }
    }

    // MARK: - 사진 그리드
    private var photoGridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("레퍼런스 사진")
                    .font(.headline)
                    .padding(.horizontal)
                Spacer()
                Text("\(folder.profiles.count)장")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }

            if folder.profiles.isEmpty {
                Text("좋아하는 스타일 사진을 추가하면\nAI가 스타일을 분석해줘요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                let columns = [GridItem(.adaptive(minimum: 100))]
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(folder.profiles.sorted(by: { $0.createdAt < $1.createdAt })) { profile in
                        if let uiImage = UIImage(data: profile.imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 110)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)

                // 분석 버튼
                Button {
                    Task { await analyzeStyle() }
                } label: {
                    Label(
                        isAnalyzing ? "분석 중..." : (folder.hasAnalysis ? "다시 분석하기" : "스타일 분석하기"),
                        systemImage: "sparkles"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isAnalyzing)
                .padding(.horizontal)
                .overlay {
                    if isAnalyzing { ProgressView() }
                }
            }
        }
    }

    // MARK: - 분석 결과
    private var analysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("스타일 분석 결과")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(folder.analysisKeywords, id: \.self) { keyword in
                        Text(keyword)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundStyle(Color.accentColor)
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal)
            }

            Text(folder.analysisDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Actions
    private func addPhotos(_ items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                let profile = StyleProfile(imageData: data, folder: folder)
                modelContext.insert(profile)
            }
        }
        selectedPhotos = []
    }

    private func analyzeStyle() async {
        guard !folder.profiles.isEmpty else { return }
        isAnalyzing = true
        errorMessage = nil

        do {
            let images = folder.profiles.map { $0.imageData }
            let analysis = try await claudeService.analyzeStyle(images: images)
            folder.analysisKeywords = analysis.keywords
            folder.analysisDescription = analysis.description
        } catch {
            errorMessage = error.localizedDescription
        }

        isAnalyzing = false
    }
}
