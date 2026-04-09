//
//  Navigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

/*
 NavigatorProtocol의 타입 소거 래퍼입니다.

 Feature 모듈의 ViewModel은 Navigator<Route>만 주입받으며,
 StackNavigator, LegacyNavigator 등 구체 구현체를 직접 알지 않습니다.
 App 타겟의 Coordinator가 구현체를 생성하고 Navigator로 감싸 주입합니다.

 담당 역할
 - NavigatorProtocol 구현체를 클로저로 캡처하여 타입 정보 은닉
 - NavigationEventObserverProtocol 옵저버 등록 및 이벤트 전달
 - 구현체 해제 후에도 옵저버에게 이벤트를 정상적으로 전달

 메모리 안전성
 - 구현체는 [weak navigator]로 약하게 캡처합니다.
 - 구현체가 해제된 이후에는 화면 이동 클로저가 아무 동작도 하지 않습니다.
 - 옵저버는 strong 참조로 관리되므로, 순환 참조가 우려될 경우
   호출부에서 removeObserver(_:)를 통해 직접 해제해야 합니다.

 Swift 6 동시성
 - @MainActor: 모든 화면 이동과 이벤트 전달은 메인 스레드에서 실행됩니다.
 - @unchecked Sendable: @MainActor 격리를 직접 보장하므로 컴파일러 검사를 우회합니다.
 */
@MainActor
public final class Navigator<Route: Hashable>: NavigatorProtocol, @unchecked Sendable {

    private let _push:      (Route) -> Void
    private let _pop:       () -> Void
    private let _popToRoot: () -> Void
    private let _replace:   ([Route]) -> Void
    private let _popTo:     (Route) -> Void
    private let _present:   (Route, PresentationStyle) -> Void
    private let _dismiss:   () -> Void

    /*
     등록된 옵저버 목록입니다.

     동일 인스턴스의 중복 등록은 addObserver(_:) 시점에 차단되며,
     strong 참조로 유지됩니다.
     */
    private var observers: [any NavigationEventObserverProtocol] = []

    /*
     NavigatorProtocol을 채택한 구현체를 받아 Navigator를 생성합니다.

     구현체는 약하게 캡처되므로, 구현체의 생명주기는 호출부가 관리해야 합니다.

     Parameters:
     - navigator: 화면 이동을 처리할 NavigatorProtocol 구현체
     */
    public init<N: NavigatorProtocol>(_ navigator: N) where N.Route == Route {
        self._push      = { [weak navigator] route in navigator?.push(route) }
        self._pop       = { [weak navigator] in navigator?.pop() }
        self._popToRoot = { [weak navigator] in navigator?.popToRoot() }
        self._replace   = { [weak navigator] routes in navigator?.replace(with: routes) }
        self._popTo     = { [weak navigator] route in navigator?.pop(to: route) }
        self._present   = { [weak navigator] route, style in navigator?.present(route, style: style) }
        self._dismiss   = { [weak navigator] in navigator?.dismiss() }
    }

    /*
     클로저를 직접 주입하여 Navigator를 생성하는 내부 초기화입니다.

     테스트 목적으로 클로저를 직접 구성할 때 사용합니다.
     모듈 외부에서는 NavigatorProtocol 채택 구현체를 통한 초기화를 사용합니다.
     */
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

    // MARK: - NavigationEventObserverProtocol 등록

    /*
     옵저버를 등록합니다.

     동일 인스턴스를 중복으로 등록하면 첫 번째 등록만 유지됩니다.

     Parameters:
     - observer: 이벤트를 수신할 NavigationEventObserverProtocol 구현체
     */
    public func addObserver(_ observer: any NavigationEventObserverProtocol) {
        guard !observers.contains(where: { ($0 as AnyObject) === (observer as AnyObject) }) else { return }
        observers.append(observer)
    }

    /*
     등록된 옵저버를 제거합니다.

     Parameters:
     - observer: 제거할 NavigationEventObserverProtocol 구현체
     */
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
