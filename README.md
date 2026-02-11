# Navigation

Navigation 모듈은 CleanArchitectureiOSApp에서 사용되는 공통 네비게이션
기능을 제공하는 모듈입니다.

SwiftUI 기반 화면 전환을 추상화하며, iOS 15 및 iOS 16+ 환경을 모두
지원합니다.

Navigation 모듈은 화면 전환의 "구현 방식"만 담당하며, Route 정의 및 View
생성은 Application 레이어에서 담당합니다.

------------------------------------------------------------------------

## Goals

-   iOS 15 및 iOS 16+ 지원
-   SwiftUI NavigationStack 및 Legacy NavigationView 대응
-   Clean Architecture 기반 Navigation 추상화
-   Feature와 Navigation 구현 분리
-   DI 기반 Navigator 주입 지원
-   장기 유지보수성 확보

------------------------------------------------------------------------

## Architecture Role

Navigation 모듈의 역할:

-   push / pop / present / dismiss 추상화
-   iOS 버전별 Navigation 구현 분리
-   Feature가 Navigation 구현을 몰라도 되도록 인터페이스 제공

Navigation 모듈에 포함되지 않는 항목:

-   AppRoute 정의
-   View 생성 로직
-   DIContainer
-   Feature 의존성

위 항목들은 Application 레이어에서 관리됩니다.

------------------------------------------------------------------------

## Module Structure

    Navigation
    ├── Sources
    │   ├── Public
    │   │   ├── NavigatorProtocol.swift
    │   │   └── AnyNavigator.swift
    │   │
    │   ├── Stack
    │   │   └── StackNavigator.swift
    │   │
    │   └── Legacy
    │       └── LegacyNavigator.swift
    │
    └── Tests

------------------------------------------------------------------------

## Supported Platforms

-   iOS 15.0+
-   SwiftUI
-   Combine compatible

------------------------------------------------------------------------

## Core Concepts

## NavigatorProtocol

Feature는 NavigatorProtocol만 의존합니다.

``` swift
public protocol NavigatorProtocol {
    associatedtype Route: Hashable

    func push(_ route: Route)
    func pop()
    func popToRoot()

    func present(_ route: Route)
    func dismiss()
}
```

------------------------------------------------------------------------

## StackNavigator (iOS 16+)

SwiftUI NavigationStack 기반 Navigator입니다.

-   Route 기반 push/pop 관리
-   ObservableObject 기반 상태 관리

------------------------------------------------------------------------

## LegacyNavigator (iOS 15)

SwiftUI NavigationView 또는 UIKit bridge 기반 Navigator입니다.

-   iOS 15 대응
-   Closure 기반 Navigation 처리

------------------------------------------------------------------------

## AnyNavigator

Feature에서 Navigator 구현체를 숨기기 위한 type-erasure wrapper입니다.

Feature 모듈은 Navigation 구현(StackNavigator, LegacyNavigator 등)을
직접 알 필요 없이 AnyNavigator만 사용합니다.

``` swift
let navigator: AnyNavigator<AppRoute>
navigator.push(.searchDetail)
```

------------------------------------------------------------------------

## Usage

Navigation 모듈은 Application 레이어에서 생성되고 Feature 레이어로
주입됩니다.

### Application Layer

iOS 16+

``` swift
@StateObject var navigator = StackNavigator<AppRoute>()
```

iOS 15

``` swift
let navigator = LegacyNavigator<AppRoute>(...)
```

Feature로 전달:

``` swift
let anyNavigator = AnyNavigator(navigator)
```

### Feature Layer

``` swift
navigator.push(.searchDetail(trackId: id))
```

Feature는 Navigation 구현을 알 필요가 없습니다.

------------------------------------------------------------------------

## Dependency Direction

Navigation 모듈의 의존성 방향은 다음과 같습니다:

    Feature → Navigation
    Application → Navigation

    Navigation → (no dependency on Feature or Application)

Navigation 모듈은 Feature 및 Application에 의존하지 않습니다.

------------------------------------------------------------------------

## Design Principles

Navigation 모듈은 다음 설계 원칙을 따릅니다:

-   Clean Architecture
-   Dependency Inversion Principle
-   Single Responsibility Principle
-   Feature Isolation
-   Version-independent Navigation abstraction

------------------------------------------------------------------------

## Tuist Integration

Navigation 모듈은 Tuist Framework Target으로 구성됩니다.

Example:

``` swift
.target(
    name: "Navigation",
    product: .framework,
    sources: ["Sources/**"]
)
```

Application 타겟에서 dependency로 추가하여 사용합니다.

------------------------------------------------------------------------

## Future Improvements

향후 확장 예정 항목:

-   DeepLink Routing Support
-   Navigation middleware
-   Transition animation abstraction
-   Modal coordination
-   Navigation state restoration

------------------------------------------------------------------------

## License

Internal module for CleanArchitectureiOSApp.
