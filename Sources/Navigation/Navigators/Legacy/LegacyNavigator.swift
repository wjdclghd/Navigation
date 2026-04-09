//
//  LegacyNavigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

/*
 iOS 16 미만 또는 UIKit 기반 화면 이동 환경을 지원하는 타입 소거 래퍼입니다.

 NavigationStack을 사용할 수 없는 환경에서 클로저를 직접 주입하여
 NavigatorProtocol을 채택합니다. iOS 16 이상에서는 StackNavigator를
 사용하는 것이 권장됩니다.

 담당 역할
 - 외부에서 주입된 클로저를 통해 화면 이동 명령 전달
 - UIKit 기반 네비게이션 로직과의 연결 브릿지 제공

 담당하지 않는 역할
 - 화면 이동 이벤트 옵저버 알림 (Navigator 타입 소거 계층에서 처리)
 - 스택 상태 유지 및 관리 (UINavigationController 등 외부에서 담당)

 지원 정책
 - iOS 16.0 이상에서는 deprecated 경고를 표시하며 StackNavigator 사용을 권장합니다.

 Swift 6 동시성
 - @MainActor: 모든 화면 이동 명령은 메인 스레드에서 실행됩니다.
 - @unchecked Sendable: @MainActor 격리를 직접 보장하므로 컴파일러 검사를 우회합니다.
 */
@available(iOS, deprecated: 16.0, renamed: "StackNavigator")
@MainActor
public final class LegacyNavigator<Route: Hashable>: NavigatorProtocol, @unchecked Sendable {

    private let pushHandler:      (Route) -> Void
    private let popHandler:       () -> Void
    private let popToRootHandler: () -> Void
    private let replaceHandler:   ([Route]) -> Void
    private let popToHandler:     (Route) -> Void
    private let presentHandler:   (Route, PresentationStyle) -> Void
    private let dismissHandler:   () -> Void

    /*
     각 화면 이동 명령을 처리할 클로저를 주입하여 LegacyNavigator를 생성합니다.

     UIKit 기반 네비게이션 로직을 클로저 형태로 전달하며,
     NavigatorProtocol을 통해 Feature 모듈에 일관된 인터페이스를 제공합니다.

     Parameters:
     - push:      화면을 스택에 추가하는 클로저
     - pop:       최상단 화면을 스택에서 제거하는 클로저
     - popToRoot: 루트 화면까지 스택을 비우는 클로저
     - replace:   스택 전체를 새 Route 배열로 교체하는 클로저
     - popTo:     특정 Route까지 스택을 되돌리는 클로저
     - present:   모달로 화면을 표시하는 클로저
     - dismiss:   표시 중인 모달을 닫는 클로저
     */
    public init(
        push:      @escaping (Route) -> Void,
        pop:       @escaping () -> Void,
        popToRoot: @escaping () -> Void,
        replace:   @escaping ([Route]) -> Void,
        popTo:     @escaping (Route) -> Void,
        present:   @escaping (Route, PresentationStyle) -> Void,
        dismiss:   @escaping () -> Void
    ) {
        self.pushHandler      = push
        self.popHandler       = pop
        self.popToRootHandler = popToRoot
        self.replaceHandler   = replace
        self.popToHandler     = popTo
        self.presentHandler   = present
        self.dismissHandler   = dismiss
    }

    public func push(_ route: Route)                              { pushHandler(route) }
    public func pop()                                             { popHandler() }
    public func popToRoot()                                       { popToRootHandler() }
    public func replace(with routes: [Route])                     { replaceHandler(routes) }
    public func pop(to route: Route)                              { popToHandler(route) }
    public func present(_ route: Route, style: PresentationStyle) { presentHandler(route, style) }
    public func dismiss()                                         { dismissHandler() }
}
