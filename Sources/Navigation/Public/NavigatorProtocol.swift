//
//  NavigatorProtocol.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

@MainActor
public protocol NavigatorProtocol: AnyObject, Sendable {
    associatedtype Route: Hashable

    func push(_ route: Route)
    func pop()
    func popToRoot()
    func replace(with routes: [Route])
    func pop(to route: Route)

    func present(_ route: Route, style: PresentationStyle)
    func dismiss()
}
