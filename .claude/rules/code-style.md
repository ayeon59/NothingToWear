# Code Style

## Swift / SwiftUI

- 들여쓰기: 4 spaces (탭 X)
- 파일 하나에 타입 하나 원칙 (작은 helper struct 예외)
- `View` 는 body 외 로직 최소화 — 복잡한 로직은 ViewModel 또는 별도 함수로 분리
- `@Observable` 사용 (iOS 17+), `ObservableObject`/`@Published` 지양
- `private` 접근제한자를 기본으로, 필요할 때만 넓힘

## 네이밍

- View: `~View` 또는 `~Screen` 접미사 (예: `ClosetView`, `OutfitDetailScreen`)
- ViewModel: `~ViewModel` 접미사
- 프로토콜: 기능 설명형 (예: `Fetchable`, `Persistable`)

## 파일 헤더

Xcode 자동생성 헤더 주석(// Created by ...) 삭제하지 않는다.
