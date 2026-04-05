# Security

## API 키 / 시크릿

- API 키, 토큰은 코드에 하드코딩 금지
- `Config.xcconfig` 또는 환경변수로 관리하고 `.gitignore`에 추가
- `Info.plist`에 직접 시크릿 삽입 금지 (빌드 설정 변수 `$(API_KEY)` 경유)

## 데이터 저장

- 민감 정보(토큰, 사용자 인증 정보)는 반드시 Keychain에 저장
- `UserDefaults`에는 민감 정보 저장 금지

## 네트워크

- HTTP 허용하지 않음 (ATS 기본 설정 유지)
- 인증서 피닝 필요 시 `URLSessionDelegate` 구현
