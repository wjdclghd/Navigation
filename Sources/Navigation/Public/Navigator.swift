//
//  Navigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Foundation

public final class Navigator<Route: Hashable>: NavigatorProtocol {

    private let _push: (Route) -> Void
    private let _pop: () -> Void
    private let _popToRoot: () -> Void
    private let _present: (Route) -> Void
    private let _dismiss: () -> Void

    public init<N: NavigatorProtocol>(_ navigator: N) where N.Route == Route {
        self._push = navigator.push
        self._pop = navigator.pop
        self._popToRoot = navigator.popToRoot
        self._present = navigator.present
        self._dismiss = navigator.dismiss
    }

    public init(
        push: @escaping (Route) -> Void,
        pop: @escaping () -> Void,
        popToRoot: @escaping () -> Void,
        present: @escaping (Route) -> Void,
        dismiss: @escaping () -> Void
    ) {
        self._push = push
        self._pop = pop
        self._popToRoot = popToRoot
        self._present = present
        self._dismiss = dismiss
    }

    public func push(_ route: Route) { _push(route) }
    public func pop() { _pop() }
    public func popToRoot() { _popToRoot() }
    public func present(_ route: Route) { _present(route) }
    public func dismiss() { _dismiss() }
}
