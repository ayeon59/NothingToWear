import Foundation

// SwiftData에 저장하지 않고 매번 Claude에게 요청해서 받아오는 구조
struct OutfitSuggestion: Identifiable {
    var id: UUID = UUID()
    var items: [ClothingItem]   // 추천 조합에 포함된 옷들
    var description: String     // 코디 설명
    var stylingTip: String      // 스타일링 팁
}
