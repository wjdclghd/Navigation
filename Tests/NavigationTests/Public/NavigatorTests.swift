//
//  NavigatorTests.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Foundation
import Testing
@testable import Navigation

private enum TestRoute: Hashable {
    case a
    case b
}

@MainActor
final class NavigatorTests {
    @Test
    func navigator_forwardsCommands() {
        let spy = NavigatorSpy()
        let navigator = Navigator(spy)

        navigator.push(.a)
        navigator.present(.b)
        navigator.pop()
        navigator.popToRoot()
        navigator.dismiss()

        #expect(spy.pushCount == 1)
        #expect(spy.presentCount == 1)
        #expect(spy.popCount == 1)
        #expect(spy.popToRootCount == 1)
        #expect(spy.dismissCount == 1)
    }
}

@MainActor
private final class NavigatorSpy: NavigatorProtocol {
    typealias Route = TestRoute

    private(set) var pushCount: Int = 0
    private(set) var popCount: Int = 0
    private(set) var popToRootCount: Int = 0
    private(set) var presentCount: Int = 0
    private(set) var dismissCount: Int = 0

    func push(_ route: TestRoute) { pushCount += 1 }
    func pop() { popCount += 1 }
    func popToRoot() { popToRootCount += 1 }
    func present(_ route: TestRoute) { presentCount += 1 }
    func dismiss() { dismissCount += 1 }
}
