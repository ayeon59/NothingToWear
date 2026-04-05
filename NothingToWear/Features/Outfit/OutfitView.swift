import SwiftUI
import SwiftData

struct OutfitView: View {
    @Query private var clothes: [ClothingItem]
    @Query private var styleProfiles: [StyleProfile]

    @State private var suggestions: [OutfitSuggestion] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var styleAnalysis: StyleAnalysis?

    private let claudeService = ClaudeService()

    var body: some View {
        NavigationStack {
            Group {
                if clothes.isEmpty {
                    ContentUnavailableView(
                        "옷장이 비어있어요",
                        systemImage: "tshirt",
                        description: Text("먼저 옷장 탭에서 옷을 등록해주세요")
                    )
                } else if suggestions.isEmpty {
                    requestView
                } else {
                    suggestionsListView
                }
            }
            .navigationTitle("코디 추천")
        }
    }

    private var requestView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(Color.accentColor)

            Text("AI 코디 추천")
                .font(.title2.bold())

            Text("등록된 옷 \(clothes.count)개로\n오늘의 코디를 추천받아보세요")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                Task { await requestSuggestions() }
            } label: {
                Label(isLoading ? "추천 받는 중..." : "코디 추천받기", systemImage: "sparkles")
                    .frame(width: 220)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isLoading)
            .overlay {
                if isLoading { ProgressView() }
            }
        }
        .padding()
    }

    private var suggestionsListView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(suggestions) { suggestion in
                    OutfitCard(suggestion: suggestion)
                }

                Button("다시 추천받기") {
                    suggestions = []
                }
                .padding(.top)
            }
            .padding()
        }
    }

    private func requestSuggestions() async {
        isLoading = true
        errorMessage = nil

        do {
            // 스타일 분석이 없으면 기본값 사용
            let analysis = styleAnalysis ?? StyleAnalysis(
                keywords: ["베이직", "캐주얼"],
                description: "편안하고 자연스러운 데일리 스타일"
            )
            suggestions = try await claudeService.suggestOutfits(
                clothes: clothes,
                styleAnalysis: analysis
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

private struct OutfitCard: View {
    let suggestion: OutfitSuggestion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 옷 이미지 가로 스크롤
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(suggestion.items) { item in
                        if let uiImage = UIImage(data: item.imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(10)
                        }
                    }
                }
            }

            Text(suggestion.description)
                .font(.subheadline)

            if !suggestion.stylingTip.isEmpty {
                Label(suggestion.stylingTip, systemImage: "lightbulb")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}
