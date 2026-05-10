//
//  Navigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

/// `NavigatorProtocol`의 타입 소거 래퍼입니다.
///
/// Feature 모듈은 구체 구현체 대신 이 타입을 주입받아 화면 이동을 요청합니다.
@MainActor
public final class Navigator<Route: Hashable>: NavigatorProtocol, @unchecked Sendable {

    private let _push:      (Route) -> Void
    private let _pop:       () -> Void
    private let _popToRoot: () -> Void
    private let _replace:   ([Route]) -> Void
    private let _popTo:     (Route) -> Void
    private let _present:   (Route, PresentationStyle) -> Void
    private let _dismiss:   () -> Void

    private var observers: [any NavigationEventObserverProtocol] = []

    /// `NavigatorProtocol`을 채택한 구현체를 받아 Navigator를 생성합니다.
    ///
    /// 구현체는 약하게 캡처되므로 구현체의 생명주기는 호출부가 관리합니다.
    ///
    /// - Parameter navigator: 화면 이동을 처리할 구현체입니다.
    public init<N: NavigatorProtocol>(_ navigator: N) where N.Route == Route {
        self._push      = { [weak navigator] route in navigator?.push(route) }
        self._pop       = { [weak navigator] in navigator?.pop() }
        self._popToRoot = { [weak navigator] in navigator?.popToRoot() }
        self._replace   = { [weak navigator] routes in navigator?.replace(with: routes) }
        self._popTo     = { [weak navigator] route in navigator?.pop(to: route) }
        self._present   = { [weak navigator] route, style in navigator?.present(route, style: style) }
        self._dismiss   = { [weak navigator] in navigator?.dismiss() }
    }

    /// 클로저를 직접 주입하여 Navigator를 생성합니다.
    ///
    /// 테스트에서 화면 이동 동작을 직접 구성할 때 사용합니다.
    internal init(
        push:      @escaping (Route) -> Void,
        pop:       @escaping () -> Void,
        popToRoot: @escaping () -> Void,
        replace:   @escaping ([Route]) -> Void,
        popTo:     @escaping (Route) -> Void,
        present:   @escaping (Route, PresentationStyle) -> Void,
        dismiss:   @escaping () -> Void
    ) {
        self._push      = push
        self._pop       = pop
        self._popToRoot = popToRoot
        self._replace   = replace
        self._popTo     = popTo
        self._present   = present
        self._dismiss   = dismiss
    }

    // MARK: - Observer

    /// 옵저버를 등록합니다.
    ///
    /// 동일 인스턴스를 중복으로 등록하면 첫 번째 등록만 유지됩니다.
    ///
    /// - Parameter observer: 이벤트를 수신할 옵저버입니다.
    public func addObserver(_ observer: any NavigationEventObserverProtocol) {
        guard !observers.contains(where: { ($0 as AnyObject) === (observer as AnyObject) }) else { return }
        observers.append(observer)
    }

    /// 등록된 옵저버를 제거합니다.
    ///
    /// - Parameter observer: 제거할 옵저버입니다.
    public func removeObserver(_ observer: any NavigationEventObserverProtocol) {
        observers.removeAll { ($0 as AnyObject) === (observer as AnyObject) }
    }

    // MARK: - NavigatorProtocol

    public func push(_ route: Route) {
        _push(route)
        observers.forEach { $0.didPush(route: AnyHashable(route)) }
    }

    public func pop() {
        _pop()
        observers.forEach { $0.didPop() }
    }

    public func popToRoot() {
        _popToRoot()
        observers.forEach { $0.didPopToRoot() }
    }

    public func replace(with routes: [Route]) {
        _replace(routes)
        observers.forEach { $0.didReplace(with: routes.map { AnyHashable($0) }) }
    }

    public func pop(to route: Route) {
        _popTo(route)
        observers.forEach { $0.didPopTo(route: AnyHashable(route)) }
    }

    public func present(_ route: Route, style: PresentationStyle) {
        _present(route, style)
        observers.forEach { $0.didPresent(route: AnyHashable(route), style: style) }
    }

    public func dismiss() {
        _dismiss()
        observers.forEach { $0.didDismiss() }
    }
}
