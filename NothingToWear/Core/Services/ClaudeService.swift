import Foundation

@Observable
final class ClaudeService {
    private let client: AnthropicClient

    init() {
        self.client = AnthropicClient(apiKey: AppConfig.anthropicAPIKey)
    }

    // 옷 사진 분석 → 태그 + 설명 반환
    func analyzeClothing(imageData: Data) async throws -> (tags: [String], description: String) {
        let prompt = """
        이 옷 사진을 분석해줘.
        다음 형식으로 답해줘 (다른 말 없이 이 형식만):

        태그: 색상1, 색상2, 소재, 스타일키워드1, 스타일키워드2
        설명: 한 문장으로 이 옷에 대한 설명

        예시:
        태그: 화이트, 코튼, 오버핏, 베이직, 캐주얼
        설명: 심플한 오버핏 화이트 티셔츠로 다양한 코디에 활용하기 좋은 베이직 아이템입니다.
        """

        let response = try await client.sendMessage(prompt: prompt, images: [imageData])
        return parseClothingAnalysis(response)
    }

    // 스타일 레퍼런스 사진들 분석 → 스타일 분석 결과 반환
    func analyzeStyle(images: [Data]) async throws -> StyleAnalysis {
        let prompt = """
        이 사진들은 내가 좋아하는 패션 스타일 레퍼런스야.
        내 스타일을 분석해줘.
        다음 형식으로 답해줘 (다른 말 없이 이 형식만):

        키워드: 키워드1, 키워드2, 키워드3, 키워드4, 키워드5
        설명: 2-3문장으로 전체적인 스타일 설명
        """

        let response = try await client.sendMessage(prompt: prompt, images: images)
        return parseStyleAnalysis(response)
    }

    // 코디 추천 → 추천 조합 + 설명 반환
    func suggestOutfits(
        clothes: [ClothingItem],
        styleAnalysis: StyleAnalysis
    ) async throws -> [OutfitSuggestion] {
        // 옷 목록을 텍스트로 정리
        let clothesList = clothes.enumerated().map { index, item in
            "[\(index)] \(item.category.rawValue): \(item.clothingDescription) (태그: \(item.tags.joined(separator: ", ")))"
        }.joined(separator: "\n")

        let prompt = """
        내 옷장 목록:
        \(clothesList)

        내 스타일: \(styleAnalysis.description)
        스타일 키워드: \(styleAnalysis.keywords.joined(separator: ", "))

        위 옷들로 만들 수 있는 코디 3가지를 추천해줘.
        각 코디는 다음 형식으로 (다른 말 없이 이 형식만):

        코디1:
        아이템: [0], [2], [5]
        설명: 코디 설명
        팁: 스타일링 팁

        코디2:
        아이템: [1], [3]
        설명: 코디 설명
        팁: 스타일링 팁

        코디3:
        아이템: [0], [4], [6]
        설명: 코디 설명
        팁: 스타일링 팁
        """

        let response = try await client.sendMessage(prompt: prompt)
        return parseOutfitSuggestions(response, clothes: clothes)
    }
}

// MARK: - 응답 파싱
private extension ClaudeService {
    func parseClothingAnalysis(_ text: String) -> (tags: [String], description: String) {
        var tags: [String] = []
        var description = ""

        for line in text.components(separatedBy: "\n") {
            if line.hasPrefix("태그:") {
                let tagString = line.replacingOccurrences(of: "태그:", with: "").trimmingCharacters(in: .whitespaces)
                tags = tagString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            } else if line.hasPrefix("설명:") {
                description = line.replacingOccurrences(of: "설명:", with: "").trimmingCharacters(in: .whitespaces)
            }
        }

        return (tags, description)
    }

    func parseStyleAnalysis(_ text: String) -> StyleAnalysis {
        var keywords: [String] = []
        var description = ""

        for line in text.components(separatedBy: "\n") {
            if line.hasPrefix("키워드:") {
                let kwString = line.replacingOccurrences(of: "키워드:", with: "").trimmingCharacters(in: .whitespaces)
                keywords = kwString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            } else if line.hasPrefix("설명:") {
                description = line.replacingOccurrences(of: "설명:", with: "").trimmingCharacters(in: .whitespaces)
            }
        }

        return StyleAnalysis(keywords: keywords, description: description)
    }

    func parseOutfitSuggestions(_ text: String, clothes: [ClothingItem]) -> [OutfitSuggestion] {
        var suggestions: [OutfitSuggestion] = []
        let blocks = text.components(separatedBy: "\n\n")

        for block in blocks {
            guard block.contains("아이템:") else { continue }

            var items: [ClothingItem] = []
            var description = ""
            var tip = ""

            for line in block.components(separatedBy: "\n") {
                if line.hasPrefix("아이템:") {
                    let indexString = line.replacingOccurrences(of: "아이템:", with: "")
                    let indices = indexString.components(separatedBy: ",").compactMap { part -> Int? in
                        let cleaned = part.trimmingCharacters(in: .whitespaces)
                            .replacingOccurrences(of: "[", with: "")
                            .replacingOccurrences(of: "]", with: "")
                        return Int(cleaned)
                    }
                    items = indices.compactMap { $0 < clothes.count ? clothes[$0] : nil }
                } else if line.hasPrefix("설명:") {
                    description = line.replacingOccurrences(of: "설명:", with: "").trimmingCharacters(in: .whitespaces)
                } else if line.hasPrefix("팁:") {
                    tip = line.replacingOccurrences(of: "팁:", with: "").trimmingCharacters(in: .whitespaces)
                }
            }

            if !items.isEmpty {
                suggestions.append(OutfitSuggestion(items: items, description: description, stylingTip: tip))
            }
        }

        return suggestions
    }
}
