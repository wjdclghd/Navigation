//
//  ObservableStackNavigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Observation

/// iOS 17 이상에서 `@Observable` 기반 화면 이동을 처리하는 구현체입니다.
///
/// SwiftUI View가 `path`와 `presentationItem` 변화를 자동으로 감지할 수 있도록 상태를 제공합니다.
@available(iOS 17.0, macOS 14.0, *)
@Observable
@MainActor
public final class ObservableStackNavigator<Route: Hashable>: NavigatorProtocol, @unchecked Sendable {

    /// 현재 스택의 화면 순서입니다.
    ///
    /// `NavigationStack(path:)` 바인딩에 연결하여 View가 스택 상태를 반영합니다.
    public private(set) var path: [Route] = []

    /// 현재 표시 중인 모달 정보입니다.
    ///
    /// `.sheet(item:)` 또는 `.fullScreenCover(item:)` 바인딩에 연결합니다.
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
