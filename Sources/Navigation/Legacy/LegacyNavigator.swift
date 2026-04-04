//
//  LegacyNavigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

@available(iOS, deprecated: 16.0, renamed: "StackNavigator")
@MainActor
public final class LegacyNavigator<Route: Hashable>: NavigatorProtocol {

    private let pushHandler:      (Route) -> Void
    private let popHandler:       () -> Void
    private let popToRootHandler: () -> Void
    private let presentHandler:   (Route) -> Void
    private let dismissHandler:   () -> Void

    public init(
        push:      @escaping (Route) -> Void,
        pop:       @escaping () -> Void,
        popToRoot: @escaping () -> Void,
        present:   @escaping (Route) -> Void,
        dismiss:   @escaping () -> Void
    ) {
        self.pushHandler      = push
        self.popHandler       = pop
        self.popToRootHandler = popToRoot
        self.presentHandler   = present
        self.dismissHandler   = dismiss
    }

    public func push(_ route: Route)    { pushHandler(route) }
    public func pop()                   { popHandler() }
    public func popToRoot()             { popToRootHandler() }
    public func present(_ route: Route) { presentHandler(route) }
    public func dismiss()               { dismissHandler() }
}
