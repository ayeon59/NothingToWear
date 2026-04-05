import SwiftUI
import SwiftData
import PhotosUI

struct AddClothingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedCategory: ClothingCategory = .top
    @State private var isAnalyzing = false
    @State private var errorMessage: String?

    private let claudeService = ClaudeService()

    var body: some View {
        NavigationStack {
            Form {
                Section("사진") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        if let data = selectedImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 240)
                                .cornerRadius(12)
                        } else {
                            Label("사진 선택", systemImage: "photo.badge.plus")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                }

                Section("카테고리") {
                    Picker("카테고리", selection: $selectedCategory) {
                        ForEach(ClothingCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("옷 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task { await saveClothing() }
                    }
                    .disabled(selectedImageData == nil || isAnalyzing)
                    .overlay {
                        if isAnalyzing {
                            ProgressView()
                        }
                    }
                }
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    selectedImageData = try? await newItem?.loadTransferable(type: Data.self)
                }
            }
        }
    }

    private func saveClothing() async {
        guard let imageData = selectedImageData else { return }

        isAnalyzing = true
        errorMessage = nil

        do {
            let (tags, description) = try await claudeService.analyzeClothing(imageData: imageData)
            let item = ClothingItem(imageData: imageData, category: selectedCategory)
            item.tags = tags
            item.clothingDescription = description
            modelContext.insert(item)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isAnalyzing = false
    }
}
