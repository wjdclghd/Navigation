//
//  LegacyNavigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

/// iOS 16 미만 또는 UIKit 기반 화면 이동 환경을 지원하는 클로저 주입형 구현체입니다.
///
/// iOS 16 이상에서는 `StackNavigator` 사용을 권장합니다.
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

    /// 각 화면 이동 명령을 처리할 클로저를 주입하여 LegacyNavigator를 생성합니다.
    ///
    /// - Parameters:
    ///   - push: 화면을 스택에 추가하는 클로저입니다.
    ///   - pop: 최상단 화면을 스택에서 제거하는 클로저입니다.
    ///   - popToRoot: 루트 화면까지 스택을 비우는 클로저입니다.
    ///   - replace: 스택 전체를 새 Route 배열로 교체하는 클로저입니다.
    ///   - popTo: 특정 Route까지 스택을 되돌리는 클로저입니다.
    ///   - present: 모달로 화면을 표시하는 클로저입니다.
    ///   - dismiss: 표시 중인 모달을 닫는 클로저입니다.
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
