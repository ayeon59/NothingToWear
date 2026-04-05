import SwiftUI
import SwiftData

@main
struct NothingToWearApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [ClothingItem.self, StyleProfile.self, SavedOutfit.self])
    }
}
