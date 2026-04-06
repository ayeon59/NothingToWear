import SwiftData
import Foundation

@Model
final class StyleProfile {
    var id: UUID
    var imageData: Data
    var createdAt: Date
    var folder: StyleFolder?

    init(imageData: Data, folder: StyleFolder? = nil) {
        self.id = UUID()
        self.imageData = imageData
        self.createdAt = Date()
        self.folder = folder
    }
}

struct StyleAnalysis {
    var keywords: [String]
    var description: String
}
