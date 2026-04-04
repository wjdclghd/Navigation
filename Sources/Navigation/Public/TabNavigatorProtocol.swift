//
//  TabNavigatorProtocol.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

@MainActor
public protocol TabNavigatorProtocol: AnyObject, Sendable {
    associatedtype Tab: Hashable
    var selectedTab: Tab { get }
    func select(_ tab: Tab)
}
