import Foundation

enum AppConfig {
    static var anthropicAPIKey: String {
        let raw = Bundle.main.infoDictionary?["ANTHROPIC_API_KEY"]
        print("[AppConfig] ANTHROPIC_API_KEY raw value: \(String(describing: raw))")
        guard let key = (raw as? String)?.trimmingCharacters(in: .whitespaces), !key.isEmpty else {
            fatalError("ANTHROPIC_API_KEY가 Info.plist에 설정되지 않았습니다.")
        }
        print("[AppConfig] Key prefix: \(key.prefix(20))")
        return key
    }
}
