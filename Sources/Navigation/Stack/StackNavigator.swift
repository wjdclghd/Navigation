//
//  StackNavigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import SwiftUI

@available(iOS 16.0, *)
@MainActor
public final class StackNavigator<Route: Hashable>: ObservableObject, NavigatorProtocol {

    @Published public private(set) var path: [Route] = []
    @Published public private(set) var presented: Route?

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

    public func present(_ route: Route) {
        presented = route
    }

    public func dismiss() {
        presented = nil
    }
}
