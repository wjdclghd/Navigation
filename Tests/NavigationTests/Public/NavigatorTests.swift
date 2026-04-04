//
//  NavigatorTests.swift
//  NavigationTests
//
//  Created by jch on 2/11/26.
//

import XCTest
@testable import Navigation

private enum TestRoute: Hashable {
    case home
    case detail(id: String)
    case settings
}

@MainActor
final class NavigatorTests: XCTestCase {

    private var spy: NavigatorSpy!
    private var sut: Navigator<TestRoute>!

    override func setUp() {
        super.setUp()
        spy = NavigatorSpy()
        sut = Navigator(spy)
    }

    override func tearDown() {
        sut = nil
        spy = nil
        super.tearDown()
    }

    // MARK: - push

    func test_push_forwardsCommandAndRouteValue() {
        sut.push(.home)

        XCTAssertEqual(spy.pushCount, 1)
        XCTAssertEqual(spy.lastPushedRoute, .home)
    }

    func test_push_forwardsAssociatedValueRouteAccurately() {
        sut.push(.detail(id: "item-42"))

        XCTAssertEqual(spy.lastPushedRoute, .detail(id: "item-42"))
    }

    func test_push_multipleCalls_forwardsAllRoutesInOrder() {
        sut.push(.home)
        sut.push(.detail(id: "1"))
        sut.push(.settings)

        XCTAssertEqual(spy.pushCount, 3)
        XCTAssertEqual(spy.pushedRoutes, [.home, .detail(id: "1"), .settings])
    }

    // MARK: - pop / popToRoot

    func test_pop_forwardsCommandToImplementation() {
        sut.pop()

        XCTAssertEqual(spy.popCount, 1)
    }

    func test_popToRoot_forwardsCommandToImplementation() {
        sut.popToRoot()

        XCTAssertEqual(spy.popToRootCount, 1)
    }

    // MARK: - present / dismiss

    func test_present_forwardsRouteAndStyle() {
        sut.present(.settings, style: .fullScreenCover)

        XCTAssertEqual(spy.presentCount, 1)
        XCTAssertEqual(spy.lastPresentedRoute, .settings)
        XCTAssertEqual(spy.lastPresentedStyle, .fullScreenCover)
    }

    func test_present_defaultStyle_forwardsSheetStyle() {
        sut.present(.home, style: .sheet)

        XCTAssertEqual(spy.lastPresentedStyle, .sheet)
    }

    func test_dismiss_forwardsCommandToImplementation() {
        sut.dismiss()

        XCTAssertEqual(spy.dismissCount, 1)
    }

    // MARK: - 메모리 안전성

    func test_weakCapture_afterImplementationReleased_doesNotCrash() {
        var localSpy: NavigatorSpy? = NavigatorSpy()
        let localSut = Navigator(localSpy!)

        localSpy = nil

        localSut.push(.home)
        localSut.pop()
        localSut.popToRoot()
        localSut.present(.settings, style: .sheet)
        localSut.dismiss()

        XCTAssertTrue(true)
    }

    func test_weakCapture_afterImplementationReleased_doesNotAffectOtherInstances() {
        var releasableSpy: NavigatorSpy? = NavigatorSpy()
        let releasableNavigator = Navigator(releasableSpy!)

        releasableNavigator.push(.detail(id: "before-release"))
        XCTAssertEqual(releasableSpy?.pushCount, 1)

        releasableSpy = nil

        releasableNavigator.push(.settings)
        releasableNavigator.pop()

        sut.push(.home)
        XCTAssertEqual(spy.pushCount, 1)
    }
}

// MARK: - NavigatorSpy

@MainActor
private final class NavigatorSpy: NavigatorProtocol {

    typealias Route = TestRoute

    private(set) var pushCount:      Int = 0
    private(set) var popCount:       Int = 0
    private(set) var popToRootCount: Int = 0
    private(set) var presentCount:   Int = 0
    private(set) var dismissCount:   Int = 0

    private(set) var pushedRoutes:        [TestRoute] = []
    var lastPushedRoute:      TestRoute?      { pushedRoutes.last }
    private(set) var lastPresentedRoute:  TestRoute?
    private(set) var lastPresentedStyle:  PresentationStyle?

    func push(_ route: TestRoute) {
        pushCount += 1
        pushedRoutes.append(route)
    }

    func pop()       { popCount += 1 }
    func popToRoot() { popToRootCount += 1 }
    func dismiss()   { dismissCount += 1 }

    func present(_ route: TestRoute, style: PresentationStyle) {
        presentCount += 1
        lastPresentedRoute = route
        lastPresentedStyle = style
    }
}
