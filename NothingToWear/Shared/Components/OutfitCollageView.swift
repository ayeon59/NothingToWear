import SwiftUI

struct OutfitCollageView: View {
    let items: [ClothingItem]

    // 카테고리 우선순위에 따라 분류
    private var accessories: [ClothingItem] { items.filter { $0.category == .accessory } }
    private var tops: [ClothingItem] { items.filter { $0.category == .top || $0.category == .outer || $0.category == .dress } }
    private var bottoms: [ClothingItem] { items.filter { $0.category == .bottom } }
    private var shoes: [ClothingItem] { items.filter { $0.category == .shoes } }
    private var bags: [ClothingItem] { items.filter { $0.category == .bag } }

    var body: some View {
        VStack(spacing: 8) {
            // 액세서리
            if !accessories.isEmpty {
                HStack(spacing: 8) {
                    ForEach(accessories) { item in
                        CollageItemImage(item: item, size: 60)
                    }
                }
            }

            // 상의 / 아우터 / 원피스
            if !tops.isEmpty {
                HStack(spacing: 8) {
                    ForEach(tops) { item in
                        CollageItemImage(item: item, size: tops.count == 1 ? 160 : 120)
                    }
                }
            }

            // 하의
            if !bottoms.isEmpty {
                HStack(spacing: 8) {
                    ForEach(bottoms) { item in
                        CollageItemImage(item: item, size: 140)
                    }
                }
            }

            // 신발 + 가방
            if !shoes.isEmpty || !bags.isEmpty {
                HStack(spacing: 16) {
                    ForEach(shoes) { item in
                        CollageItemImage(item: item, size: 90)
                    }
                    ForEach(bags) { item in
                        CollageItemImage(item: item, size: 90)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

private struct CollageItemImage: View {
    let item: ClothingItem
    let size: CGFloat

    var body: some View {
        if let uiImage = UIImage(data: item.imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }
}
