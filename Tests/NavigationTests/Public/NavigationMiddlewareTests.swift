//
//  NavigationMiddlewareTests.swift
//  NavigationTests
//
//  Created by jch on 2/11/26.
//

import XCTest
@testable import Navigation

// MARK: - Full Observer Spy

@MainActor
private final class FullObserverSpy: NavigationEventObserver {

    private(set) var pushedRoute:    AnyHashable?
    private(set) var popCount:       Int = 0
    private(set) var popToRootCount: Int = 0
    private(set) var replacedRoutes: [AnyHashable]?
    private(set) var popToRoute:     AnyHashable?
    private(set) var presentedRoute: AnyHashable?
    private(set) var presentedStyle: PresentationStyle?
    private(set) var dismissCount:   Int = 0
    private(set) var selectedTab:    AnyHashable?

    func didPush(route: AnyHashable) { pushedRoute = route }
    func didPop() { popCount += 1 }
    func didPopToRoot() { popToRootCount += 1 }
    func didReplace(with routes: [AnyHashable]) { replacedRoutes = routes }
    func didPopTo(route: AnyHashable) { popToRoute = route }
    func didPresent(route: AnyHashable, style: PresentationStyle) { presentedRoute = route; presentedStyle = style }
    func didDismiss() { dismissCount += 1 }
    func didSelectTab(tab: AnyHashable) { selectedTab = tab }
}

// MARK: - Partial Observer (default extension 검증용)

@MainActor
private final class PartialObserverSpy: NavigationEventObserver {
    private(set) var pushedRoute: AnyHashable?
    func didPush(route: AnyHashable) { pushedRoute = route }
}

// MARK: - Tests

@MainActor
final class NavigationMiddlewareTests: XCTestCase {

    private var sut: FullObserverSpy!

    override func setUp() {
        super.setUp()
        sut = FullObserverSpy()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - 전체 구현 옵저버

    func test_didPush_receivesRoute() {
        sut.didPush(route: AnyHashable("home"))

        XCTAssertEqual(sut.pushedRoute, AnyHashable("home"))
    }

    func test_didPop_incrementsCount() {
        sut.didPop()
        sut.didPop()

        XCTAssertEqual(sut.popCount, 2)
    }

    func test_didPopToRoot_incrementsCount() {
        sut.didPopToRoot()

        XCTAssertEqual(sut.popToRootCount, 1)
    }

    func test_didReplace_receivesRoutes() {
        let routes: [AnyHashable] = [AnyHashable("home"), AnyHashable("settings")]

        sut.didReplace(with: routes)

        XCTAssertEqual(sut.replacedRoutes, routes)
    }

    func test_didPopTo_receivesRoute() {
        sut.didPopTo(route: AnyHashable("detail"))

        XCTAssertEqual(sut.popToRoute, AnyHashable("detail"))
    }

    func test_didPresent_receivesRouteAndStyle() {
        sut.didPresent(route: AnyHashable("settings"), style: .fullScreenCover)

        XCTAssertEqual(sut.presentedRoute, AnyHashable("settings"))
        XCTAssertEqual(sut.presentedStyle, .fullScreenCover)
    }

    func test_didDismiss_incrementsCount() {
        sut.didDismiss()

        XCTAssertEqual(sut.dismissCount, 1)
    }

    func test_didSelectTab_receivesTab() {
        sut.didSelectTab(tab: AnyHashable(1))

        XCTAssertEqual(sut.selectedTab, AnyHashable(1))
    }

    // MARK: - default extension 선택적 구현 검증

    func test_partialObserver_unimplementedMethods_doNotCrash() {
        let partial = PartialObserverSpy()

        partial.didPop()
        partial.didPopToRoot()
        partial.didReplace(with: [AnyHashable("home")])
        partial.didPopTo(route: AnyHashable("settings"))
        partial.didPresent(route: AnyHashable("home"), style: .sheet)
        partial.didDismiss()
        partial.didSelectTab(tab: AnyHashable(0))

        XCTAssertTrue(true)
    }

    func test_partialObserver_implementedMethod_receivesRoute() {
        let partial = PartialObserverSpy()

        partial.didPush(route: AnyHashable("home"))

        XCTAssertEqual(partial.pushedRoute, AnyHashable("home"))
    }
}
