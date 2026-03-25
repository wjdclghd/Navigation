# Navigation

Navigation 모듈은 SwiftUI 기반 화면 전환을 추상화하는 공통 모듈입니다. iOS 15와 iOS 16+ 환경을 모두 지원하며, Feature 계층은 구현 방식(Stack/Legacy)을 알 필요 없이 동일한 인터페이스로 네비게이션 명령을 호출할 수 있습니다.

---

## Goals
- iOS 15 및 iOS 16+ 동시 지원
- NavigationStack(iOS 16+) 및 Legacy NavigationView(iOS 15) 대응
- Feature와 Navigation 구현 분리
- DI 기반 Navigator 주입 지원
- 장기 유지보수성 확보

---

## Architecture Role
Navigation 모듈이 담당하는 범위는 “화면 전환의 구현 방식”입니다.

### 포함
- push / pop / popToRoot / present / dismiss 추상화
- iOS 버전별 Navigation 구현 분리
- Feature가 구현을 몰라도 되도록 인터페이스 제공

### 제외
- AppRoute 정의
- View 생성 로직
- DIContainer
- Feature 의존성

---

## Supported Platforms
- iOS 15.0+
- SwiftUI

---

## Module Structure
```
Navigation
├── Sources
│   ├── Public
│   │   ├── NavigatorProtocol.swift
│   │   └── Navigator.swift
│   ├── Stack
│   │   └── StackNavigator.swift
│   └── Legacy
│       └── LegacyNavigator.swift
└── Tests
```

---

## Core Concepts

### NavigatorProtocol
Feature는 `NavigatorProtocol`만 의존합니다.

```swift
@MainActor
public protocol NavigatorProtocol: AnyObject {
    associatedtype Route: Hashable

    func push(_ route: Route)
    func pop()
    func popToRoot()

    func present(_ route: Route)
    func dismiss()
}
```

### Navigator (타입 소거 래퍼)
Feature에 구현체를 숨기기 위한 타입 소거 래퍼입니다.

```swift
@MainActor
public final class Navigator<Route: Hashable>: NavigatorProtocol {
    public init<N: NavigatorProtocol>(_ navigator: N) where N.Route == Route
}
```

### StackNavigator (iOS 16+)
`NavigationStack`과 바인딩되는 상태 보유형 구현입니다.

- `path`: push/pop 스택 상태
- `presented`: 모달 표시 상태

### LegacyNavigator (iOS 15)
iOS 15의 `NavigationView` 제약을 고려해, 실제 스택 관리는 호스트에서 수행하고 모듈은 명령만 위임합니다.

---

## Usage
### Application Layer
iOS 16+
```swift
@StateObject var stack = StackNavigator<AppRoute>()
let navigator = Navigator(stack)
```

iOS 15
```swift
let legacy = LegacyNavigator<AppRoute>(
    push: { _ in },
    pop: { },
    popToRoot: { },
    present: { _ in },
    dismiss: { }
)
let navigator = Navigator(legacy)
```

### Feature Layer
```swift
navigator.push(.detail(id: id))
```

---

## Threading Rule
모든 네비게이션 명령은 Main thread에서 수행해야 합니다. (API는 `@MainActor`로 제한)

---

## Dependency Direction
```
Feature → Navigation
Application → Navigation
Navigation → (no dependency on Feature or Application)
```

---

## Testing
테스트는 Xcode 프로젝트 기반으로 실행되며, CI에서는 Fastlane `scan`을 통해 구동됩니다.

---

## Tuist Integration
```swift
.target(
    name: "Navigation",
    product: .framework,
    sources: ["Sources/**"]
)
```

---

## Future Improvements
- DeepLink Routing Support
- Navigation middleware
- Transition animation abstraction
- Modal coordination
- Navigation state restoration

---

Created by: JEONG, Chi-hong
Initial version: June 2026
