# Project Overview

NothingToWear — iOS 앱 (SwiftUI). Bundle ID: `com.todayhiyeon.NothingToWear.NothingToWear`

## Build & Run

CLI 빌드:
```bash
xcodebuild -project NothingToWear.xcodeproj -scheme NothingToWear -destination 'platform=iOS Simulator,name=iPhone 16' build
```

테스트 실행:
```bash
xcodebuild -project NothingToWear.xcodeproj -scheme NothingToWear -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Tech Stack

- Swift 5.0, SwiftUI
- Deployment Target: iOS 26.2
- 패키지 매니저: SPM
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` — 프로젝트 전체 기본 액터가 MainActor

## Architecture

Feature 단위 폴더 구조:
```
NothingToWear/
├── Features/       # 기능별 View + ViewModel
├── Core/           # 네트워크, 데이터 레이어
└── Shared/         # 재사용 컴포넌트, 익스텐션
```

상태관리는 SwiftUI 기본(`@State`, `@Observable`) 우선.

## 주의사항

- `xcuserdata/`는 `.gitignore`로 제외 — 커밋하지 않는다
- `project.pbxproj`는 Xcode가 자동 관리 — 직접 편집 금지
