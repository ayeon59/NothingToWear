import SwiftData
import Foundation

@Model
final class StyleProfile {
    var id: UUID
    var imageData: Data         // 레퍼런스 사진
    var createdAt: Date

    init(imageData: Data) {
        self.id = UUID()
        self.imageData = imageData
        self.createdAt = Date()
    }
}

// SwiftData에 저장하지 않는 분석 결과 (Claude 응답용)
struct StyleAnalysis {
    var keywords: [String]      // 예: ["미니멀", "모노톤", "캐주얼"]
    var description: String     // 전체 스타일 설명
}
