//
//  ObservableStackNavigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Observation

@available(iOS 17.0, *)
@Observable
@MainActor
public final class ObservableStackNavigator<Route: Hashable>: NavigatorProtocol, @unchecked Sendable {

    public private(set) var path:             [Route]                  = []
    public private(set) var presentationItem: PresentationItem<Route>? = nil

    public init() {}

    public func push(_ route: Route) {
        path.append(route)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path.removeAll()
    }

    public func replace(with routes: [Route]) {
        path = routes
    }

    public func pop(to route: Route) {
        guard let index = path.lastIndex(of: route) else { return }
        path = Array(path.prefix(through: index))
    }

    public func present(_ route: Route, style: PresentationStyle = .sheet) {
        presentationItem = PresentationItem(route: route, style: style)
    }

    public func dismiss() {
        presentationItem = nil
    }
}
