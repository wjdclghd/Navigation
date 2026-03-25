//
//  LegacyNavigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Foundation

/// iOS 15 대응을 위한 Navigator 구현체.
/// - Note: iOS 15의 SwiftUI NavigationView 제약 때문에, 실제 스택 관리는 호스트에서 수행하고
///         여기서는 "명령"을 closure로 위임합니다.
///
/// Example:
/// ```swift
/// let legacy = LegacyNavigator<AppRoute>(
///   push: { route in ... },
///   pop: { ... },
///   popToRoot: { ... },
///   present: { route in ... },
///   dismiss: { ... }
/// )
/// let navigator = Navigator(legacy) // Feature에는 Navigator만 주입
/// ```
@MainActor
public final class LegacyNavigator<Route: Hashable>: NavigatorProtocol {

    private let pushHandler: (Route) -> Void
    private let popHandler: () -> Void
    private let popToRootHandler: () -> Void
    private let presentHandler: (Route) -> Void
    private let dismissHandler: () -> Void

    public init(
        push: @escaping (Route) -> Void,
        pop: @escaping () -> Void,
        popToRoot: @escaping () -> Void,
        present: @escaping (Route) -> Void,
        dismiss: @escaping () -> Void
    ) {
        self.pushHandler = push
        self.popHandler = pop
        self.popToRootHandler = popToRoot
        self.presentHandler = present
        self.dismissHandler = dismiss
    }

    public func push(_ route: Route) { pushHandler(route) }
    public func pop() { popHandler() }
    public func popToRoot() { popToRootHandler() }
    public func present(_ route: Route) { presentHandler(route) }
    public func dismiss() { dismissHandler() }
}
