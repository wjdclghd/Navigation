//
//  NavigationEventObserver.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Foundation

@MainActor
public protocol NavigationEventObserver: AnyObject, Sendable {
    func didPush(route: AnyHashable)
    func didPop()
    func didPopToRoot()
    func didReplace(with routes: [AnyHashable])
    func didPopTo(route: AnyHashable)
    func didPresent(route: AnyHashable, style: PresentationStyle)
    func didDismiss()
    func didSelectTab(tab: AnyHashable)
}

public extension NavigationEventObserver {
    func didPush(route: AnyHashable) {}
    func didPop() {}
    func didPopToRoot() {}
    func didReplace(with routes: [AnyHashable]) {}
    func didPopTo(route: AnyHashable) {}
    func didPresent(route: AnyHashable, style: PresentationStyle) {}
    func didDismiss() {}
    func didSelectTab(tab: AnyHashable) {}
}
