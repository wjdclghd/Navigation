//
//  StackNavigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
@MainActor
public final class StackNavigator<Route: Hashable>: ObservableObject, NavigatorProtocol {

    /// NavigationStack 경로를 표현하는 스택 상태입니다.
    @Published public var path: [Route] = []

    /// 모달(시트)로 표시되는 Route 상태입니다.
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
