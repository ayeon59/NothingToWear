# Testing

## 기본 방침

- UI 테스트보다 단위 테스트 우선
- ViewModel, 비즈니스 로직 레이어에 집중
- SwiftUI Preview를 경량 UI 검증으로 활용

## 테스트 파일 위치

`NothingToWearTests/` 타겟 아래 Feature 구조와 동일하게 미러링:
```
NothingToWearTests/
├── Features/
└── Core/
```

## 단일 테스트 실행

```bash
xcodebuild test -project NothingToWear.xcodeproj \
  -scheme NothingToWear \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:NothingToWearTests/TargetClass/testMethodName
```
