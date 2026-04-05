import SwiftUI
import SwiftData
import PhotosUI

struct StyleView: View {
    @Query private var styleProfiles: [StyleProfile]
    @Environment(\.modelContext) private var modelContext

    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var isAnalyzing = false
    @State private var styleAnalysis: StyleAnalysis?
    @State private var errorMessage: String?

    private let claudeService = ClaudeService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    referencePhotosSection
                    if let analysis = styleAnalysis {
                        analysisResultSection(analysis)
                    }
                }
                .padding()
            }
            .navigationTitle("내 스타일")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onChange(of: selectedPhotos) { _, newItems in
                Task { await addStylePhotos(newItems) }
            }
        }
    }

    private var referencePhotosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("스타일 레퍼런스")
                .font(.headline)

            if styleProfiles.isEmpty {
                Text("좋아하는 스타일 사진을 추가하면\nAI가 내 스타일을 분석해줘요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                let columns = [GridItem(.adaptive(minimum: 100))]
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(styleProfiles) { profile in
                        if let uiImage = UIImage(data: profile.imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 100)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                }

                Button {
                    Task { await analyzeStyle() }
                } label: {
                    Label(isAnalyzing ? "분석 중..." : "스타일 분석하기", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isAnalyzing)
            }
        }
    }

    private func analysisResultSection(_ analysis: StyleAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("내 스타일 분석 결과")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(analysis.keywords, id: \.self) { keyword in
                        Text(keyword)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundStyle(Color.accentColor)
                            .cornerRadius(20)
                    }
                }
            }

            Text(analysis.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func addStylePhotos(_ items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                let profile = StyleProfile(imageData: data)
                modelContext.insert(profile)
            }
        }
        selectedPhotos = []
    }

    private func analyzeStyle() async {
        isAnalyzing = true
        errorMessage = nil

        do {
            let images = styleProfiles.map { $0.imageData }
            styleAnalysis = try await claudeService.analyzeStyle(images: images)
        } catch {
            errorMessage = error.localizedDescription
        }

        isAnalyzing = false
    }
}
