import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var folders: [StyleFolder]

    var body: some View {
        TabView {
            ClosetView()
                .tabItem {
                    Label("옷장", systemImage: "tshirt")
                }

            StyleView()
                .tabItem {
                    Label("내 스타일", systemImage: "heart.text.square")
                }

            OutfitView()
                .tabItem {
                    Label("코디 추천", systemImage: "sparkles")
                }
        }
        .onAppear {
            if folders.isEmpty {
                for (name, emoji) in StyleFolder.defaultFolders {
                    modelContext.insert(StyleFolder(name: name, emoji: emoji))
                }
            }
        }
    }
}
