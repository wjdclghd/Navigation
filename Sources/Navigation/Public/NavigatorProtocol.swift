//
//  NavigatorProtocol.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

@MainActor
public protocol NavigatorProtocol: AnyObject {
    associatedtype Route: Hashable

    func push(_ route: Route)
    func pop()
    func popToRoot()

    func present(_ route: Route, style: PresentationStyle)
    func dismiss()
}
