import SwiftUI

struct RootView: View {
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
    }
}
