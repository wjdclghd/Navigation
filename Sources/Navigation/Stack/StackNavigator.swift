//
//  StackNavigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
public final class StackNavigator<Route: Hashable>: ObservableObject, NavigatorProtocol {

    @Published public var path: [Route] = []

    @Published public var presented: Route?

    public init() {}

    public func push(_ route: Route) {
        path.append(route)
    }

    public func pop() {
        _ = path.popLast()
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
