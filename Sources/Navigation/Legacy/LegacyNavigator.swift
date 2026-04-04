//
//  LegacyNavigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

@available(iOS, deprecated: 16.0, renamed: "StackNavigator")
@MainActor
public final class LegacyNavigator<Route: Hashable>: NavigatorProtocol, @unchecked Sendable {

    private let pushHandler:      (Route) -> Void
    private let popHandler:       () -> Void
    private let popToRootHandler: () -> Void
    private let replaceHandler:   ([Route]) -> Void
    private let popToHandler:     (Route) -> Void
    private let presentHandler:   (Route, PresentationStyle) -> Void
    private let dismissHandler:   () -> Void

    public init(
        push:      @escaping (Route) -> Void,
        pop:       @escaping () -> Void,
        popToRoot: @escaping () -> Void,
        replace:   @escaping ([Route]) -> Void,
        popTo:     @escaping (Route) -> Void,
        present:   @escaping (Route, PresentationStyle) -> Void,
        dismiss:   @escaping () -> Void
    ) {
        self.pushHandler      = push
        self.popHandler       = pop
        self.popToRootHandler = popToRoot
        self.replaceHandler   = replace
        self.popToHandler     = popTo
        self.presentHandler   = present
        self.dismissHandler   = dismiss
    }

    public func push(_ route: Route)                              { pushHandler(route) }
    public func pop()                                             { popHandler() }
    public func popToRoot()                                       { popToRootHandler() }
    public func replace(with routes: [Route])                     { replaceHandler(routes) }
    public func pop(to route: Route)                              { popToHandler(route) }
    public func present(_ route: Route, style: PresentationStyle) { presentHandler(route, style) }
    public func dismiss()                                         { dismissHandler() }
}
