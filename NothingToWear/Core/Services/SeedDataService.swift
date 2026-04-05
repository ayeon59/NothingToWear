import SwiftData
import UIKit

struct SeedDataService {
    // 파일명 → 카테고리 매핑
    private static let imageFiles: [(name: String, category: ClothingCategory)] = [
        ("상의1", .top),
        ("상의2", .top),
        ("하의1", .bottom),
        ("하의2", .bottom),
        ("신발1", .shoes),
        ("신발2", .shoes),
    ]

    static func seedIfNeeded(context: ModelContext) {
        for file in imageFiles {
            guard let image = UIImage(named: file.name) ?? loadFromBundle(name: file.name),
                  let data = image.jpegData(compressionQuality: 0.8) else {
                print("이미지 로드 실패: \(file.name)")
                continue
            }

            let item = ClothingItem(imageData: data, category: file.category)
            item.clothingDescription = file.name
            item.tags = [file.category.rawValue]
            context.insert(item)
        }

        print("테스트 데이터 \(imageFiles.count)개 추가 완료")
    }

    private static func loadFromBundle(name: String) -> UIImage? {
        let extensions = ["png", "jpg", "jpeg"]
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext),
               let image = UIImage(contentsOfFile: url.path) {
                return image
            }
        }
        return nil
    }
}
