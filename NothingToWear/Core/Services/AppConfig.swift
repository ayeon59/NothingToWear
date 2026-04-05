import Foundation

enum AppConfig {
    static var anthropicAPIKey: String {
        guard let key = Bundle.main.infoDictionary?["ANTHROPIC_API_KEY"] as? String,
              !key.isEmpty else {
            fatalError("ANTHROPIC_API_KEY가 Info.plist에 설정되지 않았습니다.")
        }
        return key
    }
}
