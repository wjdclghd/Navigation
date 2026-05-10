# Navigation Module

Clean Architecture + MVVM 환경에서 App 타겟이 SPM 모듈로 의존하는 형태를 전제로 만든 Navigation 모듈입니다.
이 모듈은 **화면 이동(Screen Navigation)** 역할에 집중하며, SwiftUI 기반 네비게이션 구현 방식을 외부에 직접 노출하지 않고 **공개 인터페이스 + 타입 소거 래퍼 + 내부 구현체**로 역할을 분리합니다.

모듈 내부는 특정 Feature 로직을 직접 가지지 않고,
App 타겟의 Coordinator가 구현체를 생성하여 Navigator / TabNavigator 래퍼로 감싼 뒤 ViewModel에 주입하도록 설계되어 있습니다.

**요약**
- 화면 이동 추상화: `NavigatorProtocol` + `Navigator<Route>`
- 탭 전환 추상화: `TabNavigatorProtocol` + `TabNavigator<Tab>`
- 이벤트 관찰: `NavigationEventObserverProtocol`
- 딥링크 연결: `DeepLinkHandlerProtocol`
- SwiftUI 구현체: `StackNavigator` (iOS 16+), `ObservableStackNavigator` (iOS 17+)
- UIKit 브릿지: `LegacyNavigator` (iOS 16 미만)
- 모달 모델: `PresentationStyle`, `PresentationItem`, `NavigationDetent`

---

**모듈 구조**
- Interface
  - Protocols
  - PresentationStyle.swift
- Navigators
  - Stack
  - Tab
  - Legacy

예시 구조:
```text
Navigation/
├─ Package.swift
├─ Sources/
│  └─ Navigation/
│     ├─ Interface/
│     │  ├─ PresentationStyle.swift
│     │  └─ Protocols/
│     │     ├─ NavigatorProtocol.swift
│     │     ├─ TabNavigatorProtocol.swift
│     │     ├─ NavigationEventObserverProtocol.swift
│     │     └─ DeepLinkHandlerProtocol.swift
│     └─ Navigators/
│        ├─ Stack/
│        │  ├─ Navigator.swift
│        │  ├─ StackNavigator.swift
│        │  └─ ObservableStackNavigator.swift
│        ├─ Tab/
│        │  └─ TabNavigator.swift
│        └─ Legacy/
│           └─ LegacyNavigator.swift
└─ Tests/
   └─ NavigationTests/
      ├─ Navigators/
      │  ├─ Stack/
      │  │  ├─ NavigatorTests.swift
      │  │  ├─ StackNavigatorTests.swift
      │  │  └─ ObservableStackNavigatorTests.swift
      │  ├─ Tab/
      │  │  └─ TabNavigatorTests.swift
      │  └─ Legacy/
      │     └─ LegacyNavigatorTests.swift
      └─ Protocols/
         ├─ NavigationEventObserverTests.swift
         └─ DeepLinkHandlerTests.swift
```

---

**빠른 시작**
```swift
import Navigation

// iOS 16+
let stack = StackNavigator<AppRoute>()
let navigator = Navigator(stack)

// ViewModel에 주입
let viewModel = HomeViewModel(navigator: navigator)

// ViewModel에서 화면 이동
navigator.push(.detail(id: "42"))
navigator.present(.settings, style: .sheet)
navigator.pop()
```

iOS 17 이상에서는 @Observable 기반 구현체를 사용할 수 있습니다.

```swift
import Navigation

// iOS 17+
let stack = ObservableStackNavigator<AppRoute>()
let navigator = Navigator(stack)
```

탭바 화면 전환은 TabNavigator를 사용합니다.

```swift
import Navigation

let tabNavigator = TabNavigator(myTabNavigatorImpl)

tabNavigator.select(.search)
print(tabNavigator.selectedTab)
```

---

**핵심 설계 방향**
Navigation 모듈은 다음 원칙을 기준으로 구성합니다.

- **공개 인터페이스와 구현 분리**
  - Feature 모듈은 `NavigatorProtocol`, `TabNavigatorProtocol` 계약에만 의존합니다.
  - SwiftUI의 `NavigationStack`, `@Observable` 같은 세부 구현은 내부에 감춥니다.

- **타입 소거 래퍼를 통한 구현 은닉**
  - `Navigator<Route>`, `TabNavigator<Tab>` 래퍼가 구현체를 클로저로 캡처합니다.
  - Feature 모듈은 구체 타입을 알 필요 없이 래퍼만 주입받습니다.

- **메모리 안전성**
  - 구현체는 `[weak navigator]`로 약하게 캡처합니다.
  - `TabNavigator`는 구현체 해제 후에도 `_lastKnownTab` 폴백으로 크래시를 방지합니다.

- **이벤트 옵저버 연결**
  - `NavigationEventObserverProtocol`을 통해 Analytics, 로깅 등을 Feature 코드 수정 없이 연결합니다.
  - 옵저버 등록은 `Navigator<Route>` 타입 소거 계층에서 처리합니다.

- **테스트 친화적인 구조**
  - `NavigatorProtocol`, `TabNavigatorProtocol`을 채택한 Spy로 단위 테스트가 가능합니다.
  - 구현체 해제, 폴백 동작, 이벤트 전달 모두 테스트로 검증합니다.

---

**Navigator (타입 소거 래퍼)**
`Navigator<Route>`는 `NavigatorProtocol` 구현체를 감싸는 **타입 소거 래퍼(type-erased wrapper)** 입니다.

Feature 모듈의 ViewModel은 `Navigator<Route>`만 주입받으며,
App 타겟의 Coordinator가 구체 구현체(StackNavigator 등)를 생성하고 Navigator로 감싸 주입합니다.

제공 기능:
- `push(_:)`
- `pop()`
- `popToRoot()`
- `replace(with:)`
- `pop(to:)`
- `present(_:style:)`
- `dismiss()`
- `addObserver(_:)`
- `removeObserver(_:)`

예시:
```swift
let stack = StackNavigator<AppRoute>()
let navigator = Navigator(stack)

// 옵저버 등록
navigator.addObserver(analyticsObserver)

// Feature ViewModel에 주입
let vm = DetailViewModel(navigator: navigator)
```

---

**TabNavigator (타입 소거 래퍼)**
`TabNavigator<Tab>`은 `TabNavigatorProtocol` 구현체를 감싸는 **타입 소거 래퍼** 입니다.

제공 기능:
- `select(_:)`
- `selectedTab`
- `addObserver(_:)`
- `removeObserver(_:)`

메모리 안전성:
- 구현체 해제 후에도 `_lastKnownTab` 폴백으로 `selectedTab`이 안전하게 반환됩니다.
- `select(_:)` 호출마다 폴백 값이 갱신됩니다.

예시:
```swift
let tabNavigator = TabNavigator(appTabBar)
tabNavigator.addObserver(analyticsObserver)
tabNavigator.select(.search)
```

---

**StackNavigator**
`StackNavigator<Route>`는 iOS 16 이상에서 `NavigationStack`과 연결되는 구현체입니다.

- `@Published path`: NavigationStack(path:) 바인딩에 연결합니다.
- `@Published presentationItem`: .sheet(item:) / .fullScreenCover(item:) 바인딩에 연결합니다.
- `NavigationDetent` → SwiftUI `PresentationDetent` 변환을 내부에서 처리합니다.

예시:
```swift
@StateObject var stack = StackNavigator<AppRoute>()

NavigationStack(path: $stack.path) {
    RootView()
        .sheet(item: $stack.presentationItem) { item in
            // ...
        }
}
```

---

**ObservableStackNavigator**
`ObservableStackNavigator<Route>`는 iOS 17 이상에서 `@Observable` 매크로를 사용하는 구현체입니다.

- `@Observable path`: `@StateObject` / `@ObservedObject` 없이 View에서 직접 참조합니다.
- StackNavigator와 동일한 화면 이동 인터페이스를 제공합니다.

예시:
```swift
@State var stack = ObservableStackNavigator<AppRoute>()

NavigationStack(path: $stack.path) {
    RootView()
}
```

---

**LegacyNavigator**
`LegacyNavigator<Route>`는 iOS 16 미만 또는 UIKit 기반 환경을 위한 클로저 주입형 구현체입니다.

- iOS 16.0 이상에서는 deprecated 경고를 표시하며 StackNavigator 사용을 권장합니다.
- UIKit의 UINavigationController 등 외부에서 스택 상태를 관리하고, 이 클래스는 명령만 위임합니다.

예시:
```swift
let legacy = LegacyNavigator<AppRoute>(
    push:      { route in navigationController.pushViewController(...) },
    pop:       { navigationController.popViewController(animated: true) },
    popToRoot: { navigationController.popToRootViewController(animated: true) },
    replace:   { routes in /* ... */ },
    popTo:     { route in /* ... */ },
    present:   { route, style in /* ... */ },
    dismiss:   { navigationController.dismiss(animated: true) }
)
let navigator = Navigator(legacy)
```

---

**NavigationEventObserverProtocol**
`NavigationEventObserverProtocol`은 화면 이동 이벤트를 관찰하는 **옵저버 계약** 입니다.

모든 메서드에 `default extension`으로 빈 기본 구현이 제공되므로,
필요한 이벤트만 선택적으로 구현할 수 있습니다.

제공 이벤트:
- `didPush(route:)`
- `didPop()`
- `didPopToRoot()`
- `didReplace(with:)`
- `didPopTo(route:)`
- `didPresent(route:style:)`
- `didDismiss()`
- `didSelectTab(tab:)`

예시:
```swift
final class AnalyticsObserver: NavigationEventObserverProtocol {
    func didPush(route: AnyHashable) {
        Analytics.log("push: \(route)")
    }
}

navigator.addObserver(AnalyticsObserver())
```

---

**DeepLinkHandlerProtocol**
`DeepLinkHandlerProtocol`은 URL을 Route로 변환하는 **딥링크 처리 계약** 입니다.

처리 가능 여부 판단(`canHandle`)과 변환 로직(`route(from:)`)을 분리하여,
여러 핸들러를 체인으로 연결하는 구조를 지원합니다.

예시:
```swift
struct AppDeepLinkHandler: DeepLinkHandlerProtocol {
    func canHandle(_ url: URL) -> Bool {
        url.host == "myapp.com"
    }

    func route(from url: URL) -> AppRoute? {
        switch url.path {
        case "/home":    return .home
        case "/settings": return .settings
        default:         return nil
        }
    }
}
```

---

**PresentationStyle**
모달 표시 스타일을 나타내는 열거형입니다.

- `.sheet`: 기본 시트 모달
- `.fullScreenCover`: 전체 화면 모달
- `.sheetWithDetents(Set<NavigationDetent>)`: 특정 높이로 고정되는 시트 모달

`NavigationDetent` 지원 값:
- `.medium`
- `.large`
- `.fraction(CGFloat)`
- `.height(CGFloat)`

예시:
```swift
navigator.present(.settings, style: .sheet)
navigator.present(.detail(id: "1"), style: .sheetWithDetents([.medium, .large]))
navigator.present(.fullPage, style: .fullScreenCover)
```

---

**의존 방향**
```
Feature → Navigation (NavigatorProtocol, TabNavigatorProtocol 계약에만 의존)
App     → Navigation (구현체 생성 및 Navigator 래퍼 조립)
Navigation → (Feature, App에 의존 없음)
```

---

**테스트**
모듈은 Spy 기반 단위 테스트를 포함합니다.

포함된 테스트 범위:
- `NavigatorTests` — 타입 소거 위임, 메모리 안전성
- `StackNavigatorTests` — 스택 상태 변경, 경계 조건
- `ObservableStackNavigatorTests` — @Observable 기반 상태 변경
- `TabNavigatorTests` — 탭 선택 위임, _lastKnownTab 폴백
- `LegacyNavigatorTests` — 클로저 핸들러 위임
- `NavigationEventObserverProtocolTests` — 이벤트 수신, default extension
- `DeepLinkHandlerTests` — canHandle, route 변환

테스트 전략:
- `NavigatorProtocol`, `TabNavigatorProtocol`을 채택한 Spy로 위임 동작을 검증합니다.
- 구현체 해제 후 크래시 방지, `_lastKnownTab` 폴백, 옵저버 이벤트 전달을 모두 테스트로 확인합니다.
- `DeepLinkHandlerTests`는 Stub 구현체로 계약 동작을 검증합니다.

---

**권장 사용 전략**
- Feature ViewModel은 `NavigatorProtocol`, `TabNavigatorProtocol` 계약에만 의존합니다.
- App 타겟 Coordinator는 구현체를 생성하고 Navigator / TabNavigator 래퍼로 감싸 주입합니다.
- iOS 17 이상 환경이라면 `ObservableStackNavigator`를 우선 사용합니다.
- Analytics, 로깅 연결은 `NavigationEventObserverProtocol`을 구현하여 `addObserver`로 등록합니다.
- 딥링크 처리는 `DeepLinkHandlerProtocol`을 구현하여 App 타겟 딥링크 파이프라인에 연결합니다.

---

**권장 확장 방식**

1. `Interface/Protocols`에 새 계약 추가
2. `Interface`에 새 공개 타입 추가
3. `Navigators` 하위에 새 구현체 추가
4. 새 구현체 전용 테스트 추가

---

Created by: JEONG, Chi-hong
Initial version: February 2026
