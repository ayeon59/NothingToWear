import SwiftUI
import SwiftData

struct ClosetView: View {
    @Query private var clothes: [ClothingItem]
    @State private var showAddClothing = false

    var body: some View {
        NavigationStack {
            Group {
                if clothes.isEmpty {
                    ContentUnavailableView(
                        "옷장이 비어있어요",
                        systemImage: "tshirt",
                        description: Text("옷 사진을 추가해보세요")
                    )
                } else {
                    ClothingGridView(clothes: clothes)
                }
            }
            .navigationTitle("내 옷장")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddClothing = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddClothing) {
                AddClothingView()
            }
        }
    }
}

private struct ClothingGridView: View {
    let clothes: [ClothingItem]
    let columns = [GridItem(.adaptive(minimum: 150))]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(clothes) { item in
                    ClothingCell(item: item)
                }
            }
            .padding()
        }
    }
}

private struct ClothingCell: View {
    let item: ClothingItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let uiImage = UIImage(data: item.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipped()
                    .cornerRadius(12)
            }
            Text(item.category.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
            if !item.clothingDescription.isEmpty {
                Text(item.clothingDescription)
                    .font(.caption2)
                    .lineLimit(2)
            }
        }
    }
}
