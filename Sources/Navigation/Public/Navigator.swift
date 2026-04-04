//
//  Navigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

@MainActor
public final class Navigator<Route: Hashable>: NavigatorProtocol, @unchecked Sendable {

    private let _push:      (Route) -> Void
    private let _pop:       () -> Void
    private let _popToRoot: () -> Void
    private let _replace:   ([Route]) -> Void
    private let _popTo:     (Route) -> Void
    private let _present:   (Route, PresentationStyle) -> Void
    private let _dismiss:   () -> Void

    public init<N: NavigatorProtocol>(_ navigator: N) where N.Route == Route {
        self._push      = { [weak navigator] route in navigator?.push(route) }
        self._pop       = { [weak navigator] in navigator?.pop() }
        self._popToRoot = { [weak navigator] in navigator?.popToRoot() }
        self._replace   = { [weak navigator] routes in navigator?.replace(with: routes) }
        self._popTo     = { [weak navigator] route in navigator?.pop(to: route) }
        self._present   = { [weak navigator] route, style in navigator?.present(route, style: style) }
        self._dismiss   = { [weak navigator] in navigator?.dismiss() }
    }

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

    public func push(_ route: Route)                              { _push(route) }
    public func pop()                                             { _pop() }
    public func popToRoot()                                       { _popToRoot() }
    public func replace(with routes: [Route])                     { _replace(routes) }
    public func pop(to route: Route)                              { _popTo(route) }
    public func present(_ route: Route, style: PresentationStyle) { _present(route, style) }
    public func dismiss()                                         { _dismiss() }
}
