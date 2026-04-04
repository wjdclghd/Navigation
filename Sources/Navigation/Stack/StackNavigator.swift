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

    @Published public private(set) var path:             [Route]                  = []
    @Published public private(set) var presentationItem: PresentationItem<Route>? = nil

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

    public func present(_ route: Route, style: PresentationStyle = .sheet) {
        presentationItem = PresentationItem(route: route, style: style)
    }

    public func dismiss() {
        presentationItem = nil
    }
}

@available(iOS 16.0, *)
extension NavigationDetent {
    var swiftUIDetent: PresentationDetent {
        switch self {
        case .medium:              return .medium
        case .large:               return .large
        case .fraction(let value): return .fraction(value)
        case .height(let value):   return .height(value)
        }
    }
}
