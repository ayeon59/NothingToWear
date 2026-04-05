import SwiftData
import Foundation

@Model
final class SavedOutfit {
    var id: UUID
    var outfitDescription: String
    var stylingTip: String
    var mood: String
    var createdAt: Date

    @Relationship var items: [ClothingItem]

    init(outfitDescription: String, stylingTip: String, mood: String, items: [ClothingItem]) {
        self.id = UUID()
        self.outfitDescription = outfitDescription
        self.stylingTip = stylingTip
        self.mood = mood
        self.items = items
        self.createdAt = Date()
    }
}
