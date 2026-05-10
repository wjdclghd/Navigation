//
//  StackNavigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import SwiftUI

/// iOS 16 이상에서 `NavigationStack` 기반 화면 이동을 처리하는 구현체입니다.
///
/// `path`와 `presentationItem`을 SwiftUI View에 바인딩하여 화면 상태를 제공합니다.
@available(iOS 16.0, macOS 13.0, *)
@MainActor
public final class StackNavigator<Route: Hashable>: ObservableObject, NavigatorProtocol, @unchecked Sendable {

    /// 현재 스택의 화면 순서입니다.
    ///
    /// `NavigationStack(path:)` 바인딩에 연결하여 View가 스택 상태를 반영합니다.
    @Published public private(set) var path: [Route] = []

    /// 현재 표시 중인 모달 정보입니다.
    ///
    /// `.sheet(item:)` 또는 `.fullScreenCover(item:)` 바인딩에 연결합니다.
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

/// Navigation 모듈의 `NavigationDetent`를 SwiftUI의 `PresentationDetent`로 변환합니다.
@available(iOS 16.0, macOS 13.0, *)
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
