import SwiftData
import SwiftUI

@Model
final class ClothingItem {
    var id: UUID
    var imageData: Data
    var category: ClothingCategory
    var tags: [String]               // Claude가 분석한 태그 (색상, 소재, 스타일 등)
    var clothingDescription: String  // Claude가 생성한 설명
    var createdAt: Date

    init(imageData: Data, category: ClothingCategory) {
        self.id = UUID()
        self.imageData = imageData
        self.category = category
        self.tags = []
        self.clothingDescription = ""
        self.createdAt = Date()
    }
}

enum ClothingCategory: String, Codable, CaseIterable {
    case top = "상의"
    case bottom = "하의"
    case outer = "아우터"
    case dress = "원피스/세트"
    case shoes = "신발"
    case accessory = "액세서리"
    case bag = "가방"
}
