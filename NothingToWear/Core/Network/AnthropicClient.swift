import Foundation

struct AnthropicClient {
    private let apiKey: String
    private let baseURL = "https://api.anthropic.com/v1/messages"
    private let model = "claude-haiku-4-5-20251001"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // 이미지 여러 장 + 텍스트 프롬프트를 보내고 텍스트 응답을 받는 범용 메서드
    func sendMessage(prompt: String, images: [Data] = []) async throws -> String {
        var contentBlocks: [[String: Any]] = []

        // 이미지 블록 추가
        for imageData in images {
            let base64 = imageData.base64EncodedString()
            let mediaType = imageData.imageMediaType
            contentBlocks.append([
                "type": "image",
                "source": [
                    "type": "base64",
                    "media_type": mediaType,
                    "data": base64
                ]
            ])
        }

        // 텍스트 블록 추가
        contentBlocks.append([
            "type": "text",
            "text": prompt
        ])

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 1024,
            "messages": [
                ["role": "user", "content": contentBlocks]
            ]
        ]

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AnthropicError.apiError(errorBody)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstBlock = content.first,
              let text = firstBlock["text"] as? String else {
            throw AnthropicError.invalidResponse
        }

        return text
    }
}

enum AnthropicError: LocalizedError {
    case apiError(String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .apiError(let message): return "API 오류: \(message)"
        case .invalidResponse: return "응답 형식이 올바르지 않습니다."
        }
    }
}
