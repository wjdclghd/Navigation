# Navigation Module

Clean Architecture + MVVM 환경에서 App 타겟이 SPM 모듈로 의존하는 형태를 전제로 만든 Navigation 모듈입니다.
이 모듈은 **화면 이동(Screen Navigation)** 역할에 집중하며, SwiftUI의 `NavigationStack`, `@Observable` 같은 구현 세부사항을 외부에 직접 노출하지 않고 **공개 인터페이스 + 타입 소거 래퍼 + 내부 구현체**로 역할을 분리합니다.

모듈 내부는 스택 기반 화면 이동, 탭 전환, 모달 표시, 이벤트 관찰, 딥링크 처리 기능을 포함하며,
상위 계층은 `Navigator<Route>`, `TabNavigator<Tab>` 래퍼를 주입받아 즉시 사용할 수 있습니다.

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
│        │  ├─ Navigator.swift               ← 타입 소거 래퍼
│        │  ├─ StackNavigator.swift          ← iOS 16+ 구현체
│        │  └─ ObservableStackNavigator.swift ← iOS 17+ 구현체
│        ├─ Tab/
│        │  └─ TabNavigator.swift            ← 타입 소거 래퍼
│        └─ Legacy/
│           └─ LegacyNavigator.swift         ← iOS 16 미만 구현체
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

`Navigator<Route>`와 구현체를 조합하여 즉시 화면 이동을 처리할 수 있습니다.

```swift
import Navigation

// iOS 16+
let stack = StackNavigator<AppRoute>()
let navigator = Navigator(stack)

navigator.push(.detail(id: 42))
navigator.present(.settings, style: .sheet)
navigator.pop()
navigator.popToRoot()
```

iOS 17 이상에서는 `@Observable` 기반 구현체를 사용합니다.

```swift
import Navigation

// iOS 17+
let stack = ObservableStackNavigator<AppRoute>()
let navigator = Navigator(stack)
```

iOS 15를 지원하는 Legacy 환경에서는 클로저 주입형 구현체를 사용합니다.

```swift
import Navigation

// iOS 15 (LegacyNavigator는 iOS 16 이상에서 deprecated)
let legacy = LegacyNavigator<AppRoute>(
    push:      { route in /* UINavigationController.pushViewController */ },
    pop:       { /* popViewController */ },
    popToRoot: { /* popToRootViewController */ },
    replace:   { routes in /* ... */ },
    popTo:     { route in /* ... */ },
    present:   { route, style in /* ... */ },
    dismiss:   { /* dismiss */ }
)
let navigator = Navigator(legacy)
```

탭 전환은 `TabNavigator`를 사용합니다.

```swift
import Navigation

let tabNavigator = TabNavigator(myTabCoordinator)

tabNavigator.select(.search)
print(tabNavigator.selectedTab)  // .search

tabNavigator.addObserver(analyticsObserver)
```

---

**핵심 설계 방향**

Navigation 모듈은 다음 원칙을 기준으로 구성합니다.

- **공개 인터페이스와 구현 분리**
  Feature 모듈은 `NavigatorProtocol`, `TabNavigatorProtocol` 계약에만 의존합니다.
  SwiftUI의 `NavigationStack`, `@Observable`, `PresentationDetent` 같은 세부 구현은 내부에 감춥니다.

- **타입 소거 래퍼를 통한 구현 은닉**
  `Navigator<Route>`, `TabNavigator<Tab>` 래퍼가 구현체를 클로저로 캡처합니다.
  Feature 모듈은 구체 타입을 알 필요 없이 래퍼만 주입받습니다.

- **메모리 안전성**
  구현체는 `[weak navigator]`로 약하게 캡처합니다.
  `TabNavigator`는 구현체 해제 후에도 `_lastKnownTab` 폴백으로 크래시를 방지합니다.

- **이벤트 옵저버 연결**
  `NavigationEventObserverProtocol`을 통해 Analytics, 로깅 등을 Feature 코드 수정 없이 연결합니다.
  옵저버 등록은 `Navigator<Route>` 타입 소거 계층에서 처리합니다.

- **테스트 친화적인 구조**
  `NavigatorProtocol`, `TabNavigatorProtocol`을 채택한 Spy로 단위 테스트가 가능합니다.
  구현체 해제, 폴백 동작, 이벤트 전달 모두 테스트로 검증합니다.

---

**NavigatorProtocol**

`NavigatorProtocol`은 스택 기반 화면 이동을 추상화하는 공개 계약입니다.
Feature 모듈의 ViewModel은 이 계약을 통해 화면 이동을 요청하고 구체 구현체를 직접 알지 않습니다.

```swift
@MainActor
public protocol NavigatorProtocol: AnyObject, Sendable {
    associatedtype Route: Hashable

    func push(_ route: Route)
    func pop()
    func popToRoot()
    func replace(with routes: [Route])
    func pop(to route: Route)
    func present(_ route: Route, style: PresentationStyle)
    func dismiss()
}
```

---

**TabNavigatorProtocol**

`TabNavigatorProtocol`은 탭바 기반 화면 전환을 추상화하는 공개 계약입니다.
Feature 모듈은 이 계약을 통해 탭을 전환하고 구체 구현체를 직접 알지 않습니다.

```swift
@MainActor
public protocol TabNavigatorProtocol: AnyObject, Sendable {
    associatedtype Tab: Hashable

    var selectedTab: Tab { get }
    func select(_ tab: Tab)
}
```

---

**Navigator (타입 소거 래퍼)**

`Navigator<Route>`는 `NavigatorProtocol` 구현체를 감싸는 **타입 소거 래퍼(type-erased wrapper)** 입니다.
Feature 모듈의 ViewModel은 `Navigator<Route>`만 주입받으며,
App 타겟의 Navigator (HomeNavigator 등)가 구체 구현체(StackNavigator 등)를 생성하고 래퍼로 감싸 주입합니다.

구현체는 `[weak navigator]`로 약하게 캡처되어 구현체 해제 후에도 크래시가 발생하지 않습니다.

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

```swift
let stack = StackNavigator<HomeRoute>()
let navigator = Navigator(stack)

// 옵저버 등록
navigator.addObserver(analyticsObserver)

// App Target의 HomeNavigator에 주입
let homeNavigator = HomeNavigator(navigator: navigator)
```

동일 인스턴스의 중복 옵저버 등록은 첫 번째 등록만 유지합니다.

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

```swift
let tabNavigator = TabNavigator(tabBarCoordinator)
tabNavigator.addObserver(analyticsObserver)
tabNavigator.select(.account)
print(tabNavigator.selectedTab)  // .account
```

---

**StackNavigator**

`StackNavigator<Route>`는 iOS 16 이상에서 `NavigationStack`과 연결되는 `ObservableObject` 기반 구현체입니다.

- `@Published path`: `NavigationStack(path:)` 바인딩에 연결합니다.
- `@Published presentationItem`: `.sheet(item:)` / `.fullScreenCover(item:)` 바인딩에 연결합니다.
- `NavigationDetent` → SwiftUI `PresentationDetent` 변환을 내부에서 처리합니다.

```swift
@available(iOS 16.0, *)
struct HomeStackNavigationView: View {
    @StateObject private var stack: StackNavigator<HomeRoute>

    init(container: DIContainer) {
        let stack = StackNavigator<HomeRoute>()
        self._stack = StateObject(wrappedValue: stack)
        self.homeNavigator = HomeNavigator(navigator: Navigator(stack))
    }

    var body: some View {
        NavigationStack(
            path: Binding(
                get: { stack.path },
                set: { stack.replace(with: $0) }
            )
        ) {
            RootView()
                .navigationDestination(for: HomeRoute.self) { route in
                    routeBuilder.build(route, navigator: homeNavigator)
                }
        }
        .sheet(
            item: Binding<PresentationItem<HomeRoute>?>(
                get: {
                    guard let item = stack.presentationItem,
                          item.style != .fullScreenCover else { return nil }
                    return item
                },
                set: { newValue, _ in if newValue == nil { stack.dismiss() } }
            )
        ) { item in
            routeBuilder.build(item.route, navigator: homeNavigator)
        }
    }
}
```

---

**ObservableStackNavigator**

`ObservableStackNavigator<Route>`는 iOS 17 이상에서 `@Observable` 매크로를 사용하는 구현체입니다.

- `path`, `presentationItem`의 상태 변화를 `@StateObject` 없이 View가 자동으로 감지합니다.
- `StackNavigator`와 동일한 화면 이동 인터페이스를 제공합니다.

```swift
@available(iOS 17.0, *)
struct ExampleView: View {
    @State private var stack = ObservableStackNavigator<AppRoute>()

    var body: some View {
        NavigationStack(path: Binding(
            get: { stack.path },
            set: { stack.replace(with: $0) }
        )) {
            RootView()
        }
    }
}
```

---

**LegacyNavigator**

`LegacyNavigator<Route>`는 iOS 16 미만 또는 UIKit 기반 환경을 위한 클로저 주입형 구현체입니다.

- iOS 16.0 이상에서는 deprecated 경고를 표시하며 `StackNavigator` 사용을 권장합니다.
- UIKit의 `UINavigationController` 등 외부에서 스택 상태를 관리하고, 이 클래스는 명령만 위임합니다.

iOS 15를 지원하는 `LegacyNavigationView`에서는 `LegacyNavigator`와 상태 객체를 반드시
하나의 `@StateObject`(ObservableObject)에 함께 소유해야 합니다.
struct 뷰가 재생성될 때 `let` 프로퍼티로 선언된 Navigator 인스턴스와 `@StateObject` 간 연결이
끊어지는 문제를 방지하기 위함입니다.

```swift
// [weak self]로 @StateObject와 연결을 유지합니다.
@MainActor
final class HomeLegacyNavigationController: ObservableObject {
    @Published var stack: [HomeRoute] = []
    @Published var presentationItem: PresentationItem<HomeRoute>?

    private(set) lazy var navigator: Navigator<HomeRoute> = {
        let legacy = LegacyNavigator<HomeRoute>(
            push:      { [weak self] route in self?.stack.append(route) },
            pop:       { [weak self] in _ = self?.stack.popLast() },
            popToRoot: { [weak self] in self?.stack.removeAll() },
            replace:   { [weak self] routes in self?.stack = routes },
            popTo: { [weak self] route in
                guard let self, let index = self.stack.lastIndex(of: route) else { return }
                self.stack = Array(self.stack.prefix(through: index))
            },
            present:   { [weak self] route, style in
                self?.presentationItem = PresentationItem(route: route, style: style)
            },
            dismiss:   { [weak self] in self?.presentationItem = nil }
        )
        return Navigator(legacy)
    }()
}
```

---

**NavigationEventObserverProtocol**

`NavigationEventObserverProtocol`은 화면 이동 이벤트를 관찰하는 옵저버 계약입니다.
Analytics, 로깅, 화면 이동 추적처럼 이동 이벤트를 관찰해야 하는 호출부에서 사용합니다.

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

```swift
final class AnalyticsNavigationObserver: NavigationEventObserverProtocol {
    func didPush(route: AnyHashable) {
        Analytics.log("screen_push: \(route)")
    }

    func didPresent(route: AnyHashable, style: PresentationStyle) {
        Analytics.log("screen_present: \(route)")
    }
}

navigator.addObserver(AnalyticsNavigationObserver())
```

옵저버는 `Navigator<Route>` 계층에서 관리됩니다. 동일 인스턴스의 중복 등록은 첫 번째 등록만 유지합니다.

---

**DeepLinkHandlerProtocol**

`DeepLinkHandlerProtocol`은 URL을 Route로 변환하는 딥링크 처리 계약입니다.
`canHandle`과 `route(from:)`을 분리하여 여러 핸들러를 체인으로 연결하는 구조를 지원합니다.

```swift
public protocol DeepLinkHandlerProtocol: Sendable {
    associatedtype Route: Hashable

    func canHandle(_ url: URL) -> Bool
    func route(from url: URL) -> Route?
}
```

```swift
struct HomeDeepLinkHandler: DeepLinkHandlerProtocol {
    func canHandle(_ url: URL) -> Bool {
        url.host == "myapp.com"
    }

    func route(from url: URL) -> HomeRoute? {
        switch url.path {
        case "/search":
            return .search
        case "/search/list":
            let keyword = url.queryItems?["keyword"] ?? ""
            return .searchAppStoreList(keyword: keyword)
        default:
            return nil
        }
    }
}
```

---

**현재 구현 기능**

### 1. 스택 기반 화면 이동

스택에 화면을 추가하거나 되돌립니다.

- `push(_:)`: 새 화면을 스택에 추가합니다.
- `pop()`: 최상단 화면을 스택에서 제거합니다. 빈 스택에서는 안전하게 무시합니다.
- `popToRoot()`: 스택을 루트 화면만 남도록 초기화합니다.
- `replace(with:)`: 스택 전체를 새 Route 배열로 교체합니다.
- `pop(to:)`: 특정 Route의 마지막 위치까지 스택을 되돌립니다. 존재하지 않는 Route는 무시합니다.

관련 구현: `Navigator`, `StackNavigator`, `ObservableStackNavigator`, `LegacyNavigator`

### 2. 모달 화면 표시

sheet / fullScreenCover / detent sheet 표시와 닫기를 처리합니다.

- `present(_:style:)`: `PresentationStyle`에 따라 모달을 표시합니다.
- `dismiss()`: 현재 표시 중인 모달을 닫습니다.
- `PresentationItem`: 매 `present` 호출마다 고유한 `UUID`를 생성하여 동일 Route의 반복 표시도 정상 동작합니다.

```swift
navigator.present(.settings, style: .sheet)
navigator.present(.filter, style: .sheetWithDetents([.medium, .large]))
navigator.present(.onboarding, style: .fullScreenCover)
navigator.dismiss()
```

관련 구현: `PresentationStyle`, `PresentationItem`, `NavigationDetent`, `StackNavigator`

### 3. 탭 전환

선택된 탭 상태를 관리하고 탭 전환 이벤트를 전달합니다.

- `select(_:)`: 지정한 탭으로 전환하고 등록된 옵저버에 `didSelectTab(tab:)` 이벤트를 전달합니다.
- `selectedTab`: 현재 선택된 탭을 반환합니다. 구현체 해제 후에는 `_lastKnownTab` 폴백을 반환합니다.

관련 구현: `TabNavigatorProtocol`, `TabNavigator`

### 4. 이벤트 옵저버

화면 이동 이벤트를 외부 호출부에 전달합니다.

- `addObserver(_:)`: 옵저버를 등록합니다. 동일 인스턴스 중복 등록은 무시합니다.
- `removeObserver(_:)`: 등록된 옵저버를 제거합니다.
- 모든 이동 명령 실행 후 등록된 옵저버 전체에 해당 이벤트를 전달합니다.
- `NavigationEventObserverProtocol`의 `default extension`이 선택적 구현을 지원합니다.

관련 구현: `NavigationEventObserverProtocol`, `Navigator`, `TabNavigator`

### 5. 딥링크 URL → Route 변환

URL 수신과 Route 연결 사이의 변환 책임을 분리합니다.

- `canHandle(_:)`: URL 처리 가능 여부를 판단합니다.
- `route(from:)`: URL을 Route로 변환합니다. 변환할 수 없으면 `nil`을 반환합니다.
- 여러 핸들러를 체인으로 연결하는 구조를 지원합니다.

관련 구현: `DeepLinkHandlerProtocol`

---

**공개 인터페이스 계약**

### Protocols

| 타입 | 설명 |
|---|---|
| `NavigatorProtocol` | 스택 기반 화면 이동 계약 |
| `TabNavigatorProtocol` | 탭바 전환 계약 |
| `NavigationEventObserverProtocol` | 화면 이동 이벤트 옵저버 계약 |
| `DeepLinkHandlerProtocol` | URL → Route 변환 딥링크 처리 계약 |

### Models

| 타입 | 설명 |
|---|---|
| `PresentationStyle` | 모달 표시 방식. `.sheet`, `.fullScreenCover`, `.sheetWithDetents` |
| `PresentationItem<Route>` | 모달 상태 컨테이너. UUID 기반 식별 |
| `NavigationDetent` | 시트 높이 정책. `.medium`, `.large`, `.fraction`, `.height` |

### 타입 소거 래퍼

| 타입 | 설명 |
|---|---|
| `Navigator<Route>` | `NavigatorProtocol` 타입 소거 래퍼. 옵저버 관리 포함 |
| `TabNavigator<Tab>` | `TabNavigatorProtocol` 타입 소거 래퍼. `_lastKnownTab` 폴백 포함 |

---

**내부 계층 구성**

### Interface
모듈 외부에 공개할 프로토콜과 모델을 정의합니다.
- `NavigatorProtocol`, `TabNavigatorProtocol`
- `NavigationEventObserverProtocol`, `DeepLinkHandlerProtocol`
- `PresentationStyle`, `PresentationItem`, `NavigationDetent`

### Navigators / Stack
화면 이동 타입 소거 래퍼와 구현체를 담당합니다.
- `Navigator`: 타입 소거 래퍼. 클로저 캡처 + 옵저버 관리
- `StackNavigator`: iOS 16+ `ObservableObject` + `@Published path/presentationItem`
- `ObservableStackNavigator`: iOS 17+ `@Observable` 기반

### Navigators / Tab
탭 전환 타입 소거 래퍼를 담당합니다.
- `TabNavigator`: 타입 소거 래퍼. `_lastKnownTab` 폴백 + 옵저버 관리

### Navigators / Legacy
iOS 16 미만 환경용 클로저 주입형 구현체를 담당합니다.
- `LegacyNavigator`: 각 화면 이동 명령을 클로저로 위임

---

**의존 방향**

```text
Feature     ──→  Navigation   (NavigatorProtocol, TabNavigatorProtocol 계약에만 의존)
App Target  ──→  Navigation   (구현체 생성 및 Navigator 래퍼 조립)
Navigation  ──X→ Feature, App  (역방향 의존 금지)
```

Feature 모듈의 ViewModel은 `NavigatorProtocol` 또는 Feature 전용 `CoordinatorProtocol`만 알고 있습니다.
구현체 선택과 Navigator 래퍼 조립은 App Target의 Navigator (HomeNavigator, AccountNavigator 등)가 담당합니다.

---

**iOS 버전별 구현 선택**

| iOS 버전 | 구현체 | View | 비고 |
|---|---|---|---|
| iOS 15 | `LegacyNavigator` | `NavigationView` | deprecated, iOS 16 미만에서만 사용 |
| iOS 16+ | `StackNavigator` | `NavigationStack` | 기본 권장 |
| iOS 17+ | `ObservableStackNavigator` | `NavigationStack` | `@Observable`, `@StateObject` 불필요 |

App Target의 NavigationView는 `#available(iOS 16.0, *)` 분기로 버전별 구현을 선택합니다.

```swift
struct HomeNavigationView: View {
    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                HomeStackNavigationView(container: container)
            } else {
                HomeLegacyNavigationView(container: container)
            }
        }
    }
}
```

---

**테스트**

모듈은 Spy / Stub 기반 단위 테스트를 포함합니다.

포함된 테스트 범위:
- `NavigatorTests` — 타입 소거 위임, 약한 캡처 메모리 안전성, 옵저버 이벤트 전달, 중복 등록 방지
- `StackNavigatorTests` — `path` / `presentationItem` 상태 전환, 빈 스택 pop 안전성, 존재하지 않는 Route의 `pop(to:)` 무시
- `ObservableStackNavigatorTests` — iOS 17+ `@Observable` 기반 동일 인터페이스 동작
- `TabNavigatorTests` — 탭 선택 위임, `_lastKnownTab` 폴백, 구현체 해제 후 안전성, 옵저버 이벤트
- `LegacyNavigatorTests` — 각 화면 이동 명령의 클로저 핸들러 호출 위임
- `NavigationEventObserverTests` — 전체 구현 / 선택적 구현(`default extension`) 수신, 미구현 메서드 크래시 없음
- `DeepLinkHandlerTests` — `canHandle` 판단, `route(from:)` URL → Route 변환

테스트 전략:
- `NavigatorProtocol`, `TabNavigatorProtocol`을 채택한 Spy로 위임 동작을 검증합니다.
- 구현체 해제 후 크래시 방지, `_lastKnownTab` 폴백, 중복 옵저버 등록 방지를 모두 테스트로 확인합니다.
- `DeepLinkHandlerTests`는 Stub 구현체로 URL → Route 계약 동작을 검증합니다.

---

**권장 사용 전략**
- Feature ViewModel은 `NavigatorProtocol`, `TabNavigatorProtocol` 계약에만 의존합니다.
- App Target Coordinator (HomeNavigator 등)는 구현체를 생성하고 `Navigator<Route>` / `TabNavigator<Tab>` 래퍼로 감싸 주입합니다.
- iOS 16 이상 환경이라면 `StackNavigator`를 기본으로 사용합니다.
- iOS 17 이상 전용 화면에서는 `ObservableStackNavigator`를 사용합니다.
- iOS 15 Legacy 환경에서는 `LegacyNavigator`를 `@StateObject` 기반 Controller에 통합하여 재초기화 문제를 방지합니다.
- Analytics, 로깅 연결은 `NavigationEventObserverProtocol`을 구현하여 `addObserver`로 등록합니다.
- 딥링크 처리는 `DeepLinkHandlerProtocol`을 구현하여 App Target 딥링크 파이프라인에 연결합니다.

---

**권장 확장 방식**

1. `Interface/Protocols`에 새 계약 추가
2. `Interface`에 새 공개 타입 추가
3. `Navigators/Stack`에 새 SwiftUI 구현체 추가 + 전용 테스트 추가
4. `Navigators/Tab`에 새 탭 관련 구현체 추가
5. `Navigators/Legacy`에 UIKit 환경 전용 구현체 추가
6. 새 CoordinatorProtocol 연결은 App Target Navigator에서 처리

---

Created by: JEONG, Chi-hong  
Initial version: February 2026  
Last updated: May 2026
