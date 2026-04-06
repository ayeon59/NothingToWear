import SwiftData
import Foundation

@Model
final class StyleFolder {
    var id: UUID
    var name: String
    var emoji: String
    var analysisDescription: String
    var analysisKeywords: [String]
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \StyleProfile.folder)
    var profiles: [StyleProfile]

    init(name: String, emoji: String) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.analysisDescription = ""
        self.analysisKeywords = []
        self.createdAt = Date()
        self.profiles = []
    }

    var hasAnalysis: Bool { !analysisDescription.isEmpty }

    var styleAnalysis: StyleAnalysis {
        StyleAnalysis(keywords: analysisKeywords, description: analysisDescription)
    }

    static let defaultFolders: [(name: String, emoji: String)] = [
        ("출근룩", "💼"),
        ("데이트룩", "🌸"),
        ("꾸안꾸", "✨"),
    ]
}
