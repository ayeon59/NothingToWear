import SwiftUI
import SwiftData

struct OutfitView: View {
    @Query private var clothes: [ClothingItem]
    @Environment(\.modelContext) private var modelContext

    @State private var mood: String = ""
    @State private var suggestions: [OutfitSuggestion] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showResults = false

    private let claudeService = ClaudeService()

    var body: some View {
        NavigationStack {
            if showResults {
                resultView
            } else {
                moodInputView
            }
        }
    }

    // MARK: - 무드 입력 화면
    private var moodInputView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.accentColor)

                Text("오늘 어떤 느낌으로 입고 싶어?")
                    .font(.title2.bold())

                Text("무드나 상황을 입력하면\nAI가 코디를 추천해줘요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                TextField("예: 캐주얼 데이트룩, 출근룩, 여름 피크닉", text: $mood)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 32)

                // 빠른 선택 태그
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(["캐주얼 데이트", "출근룩", "주말 나들이", "카페 브런치", "여름 휴가"], id: \.self) { tag in
                            Button(tag) {
                                mood = tag
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(mood == tag ? Color.accentColor : Color(.secondarySystemBackground))
                            .foregroundStyle(mood == tag ? .white : .primary)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 32)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                Task { await requestSuggestions() }
            } label: {
                Group {
                    if isLoading {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(.white)
                            Text("추천 받는 중...")
                        }
                    } else {
                        Label("코디 추천받기", systemImage: "sparkles")
                    }
                }
                .frame(width: 220)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(mood.trimmingCharacters(in: .whitespaces).isEmpty || isLoading || clothes.isEmpty)

            if clothes.isEmpty {
                Text("먼저 옷장 탭에서 옷을 등록해주세요")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .navigationTitle("코디 추천")
    }

    // MARK: - 추천 결과 화면
    private var resultView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("'\(mood)' 추천 코디")
                    .font(.headline)
                    .padding(.horizontal)

                Text("\(suggestions.count)가지 조합")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                ForEach(suggestions) { suggestion in
                    OutfitCard(suggestion: suggestion, mood: mood) { saved in
                        modelContext.insert(saved)
                    }
                    .padding(.horizontal)
                }

                Button {
                    suggestions = []
                    showResults = false
                } label: {
                    Label("다시 추천받기", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding()
            }
            .padding(.vertical)
        }
        .navigationTitle("추천 결과")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    suggestions = []
                    showResults = false
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }

    // MARK: - API 호출
    private func requestSuggestions() async {
        isLoading = true
        errorMessage = nil

        do {
            let analysis = StyleAnalysis(
                keywords: ["베이직", "캐주얼"],
                description: "편안하고 자연스러운 데일리 스타일"
            )
            suggestions = try await claudeService.suggestOutfits(
                clothes: clothes,
                styleAnalysis: analysis,
                mood: mood
            )
            showResults = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

// MARK: - 코디 카드
private struct OutfitCard: View {
    let suggestion: OutfitSuggestion
    let mood: String
    let onSave: (SavedOutfit) -> Void

    @State private var isSaved = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            OutfitCollageView(items: suggestion.items)

            VStack(alignment: .leading, spacing: 6) {
                Text(suggestion.description)
                    .font(.subheadline)

                if !suggestion.stylingTip.isEmpty {
                    Label(suggestion.stylingTip, systemImage: "lightbulb")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 4)

            Button {
                guard !isSaved else { return }
                let saved = SavedOutfit(
                    outfitDescription: suggestion.description,
                    stylingTip: suggestion.stylingTip,
                    mood: mood,
                    items: suggestion.items
                )
                onSave(saved)
                isSaved = true
            } label: {
                Label(isSaved ? "저장됨" : "이 코디 저장", systemImage: isSaved ? "heart.fill" : "heart")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(isSaved ? .pink : .accentColor)
            .disabled(isSaved)
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}
