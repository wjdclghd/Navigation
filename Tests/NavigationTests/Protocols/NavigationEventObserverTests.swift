//
//  NavigationEventObserverTests.swift
//  NavigationTests
//
//  Created by jch on 2/11/26.
//

import XCTest
@testable import Navigation

// MARK: - FullObserverSpy

/// NavigationEventObserverProtocol의 모든 메서드를 구현한 Spy입니다.
@MainActor
private final class FullObserverSpy: NavigationEventObserverProtocol {

    private(set) var pushedRoute:    AnyHashable?
    private(set) var popCount:       Int = 0
    private(set) var popToRootCount: Int = 0
    private(set) var replacedRoutes: [AnyHashable]?
    private(set) var popToRoute:     AnyHashable?
    private(set) var presentedRoute: AnyHashable?
    private(set) var presentedStyle: PresentationStyle?
    private(set) var dismissCount:   Int = 0
    private(set) var selectedTab:    AnyHashable?

    func didPush(route: AnyHashable)                            { pushedRoute = route }
    func didPop()                                               { popCount += 1 }
    func didPopToRoot()                                         { popToRootCount += 1 }
    func didReplace(with routes: [AnyHashable])                 { replacedRoutes = routes }
    func didPopTo(route: AnyHashable)                           { popToRoute = route }
    func didPresent(route: AnyHashable, style: PresentationStyle) { presentedRoute = route; presentedStyle = style }
    func didDismiss()                                           { dismissCount += 1 }
    func didSelectTab(tab: AnyHashable)                         { selectedTab = tab }
}

// MARK: - PartialObserverSpy

/// NavigationEventObserverProtocol에서 didPush만 구현한 Spy입니다.
@MainActor
private final class PartialObserverSpy: NavigationEventObserverProtocol {
    private(set) var pushedRoute: AnyHashable?
    func didPush(route: AnyHashable) { pushedRoute = route }
}

// MARK: - Tests

/// NavigationEventObserverProtocol의 이벤트 수신 동작과 default extension을 검증하는 테스트입니다.
final class NavigationEventObserverProtocolTests: XCTestCase {

    // MARK: - Helpers

    @MainActor
    private func makeSUT() -> FullObserverSpy {
        FullObserverSpy()
    }

    // MARK: - 전체 구현 옵저버

    @MainActor
    func test_didPush_receivesRoute() {
        // given
        let sut = makeSUT()

        // when
        sut.didPush(route: AnyHashable("home"))

        // then
        XCTAssertEqual(sut.pushedRoute, AnyHashable("home"))
    }

    @MainActor
    func test_didPop_incrementsCount() {
        // given
        let sut = makeSUT()

        // when
        sut.didPop()
        sut.didPop()

        // then
        XCTAssertEqual(sut.popCount, 2)
    }

    @MainActor
    func test_didPopToRoot_incrementsCount() {
        // given
        let sut = makeSUT()

        // when
        sut.didPopToRoot()

        // then
        XCTAssertEqual(sut.popToRootCount, 1)
    }

    @MainActor
    func test_didReplace_receivesRoutes() {
        // given
        let sut = makeSUT()
        let routes: [AnyHashable] = [AnyHashable("home"), AnyHashable("settings")]

        // when
        sut.didReplace(with: routes)

        // then
        XCTAssertEqual(sut.replacedRoutes, routes)
    }

    @MainActor
    func test_didPopTo_receivesRoute() {
        // given
        let sut = makeSUT()

        // when
        sut.didPopTo(route: AnyHashable("detail"))

        // then
        XCTAssertEqual(sut.popToRoute, AnyHashable("detail"))
    }

    @MainActor
    func test_didPresent_receivesRouteAndStyle() {
        // given
        let sut = makeSUT()

        // when
        sut.didPresent(route: AnyHashable("settings"), style: .fullScreenCover)

        // then
        XCTAssertEqual(sut.presentedRoute, AnyHashable("settings"))
        XCTAssertEqual(sut.presentedStyle, .fullScreenCover)
    }

    @MainActor
    func test_didDismiss_incrementsCount() {
        // given
        let sut = makeSUT()

        // when
        sut.didDismiss()

        // then
        XCTAssertEqual(sut.dismissCount, 1)
    }

    @MainActor
    func test_didSelectTab_receivesTab() {
        // given
        let sut = makeSUT()

        // when
        sut.didSelectTab(tab: AnyHashable(1))

        // then
        XCTAssertEqual(sut.selectedTab, AnyHashable(1))
    }

    // MARK: - default extension 선택적 구현 검증

    @MainActor
    func test_partialObserver_unimplementedMethods_doNotCrash() {
        // given
        let partial = PartialObserverSpy()

        // when
        partial.didPop()
        partial.didPopToRoot()
        partial.didReplace(with: [AnyHashable("home")])
        partial.didPopTo(route: AnyHashable("settings"))
        partial.didPresent(route: AnyHashable("home"), style: .sheet)
        partial.didDismiss()
        partial.didSelectTab(tab: AnyHashable(0))

        // then
        XCTAssertTrue(true)
    }

    @MainActor
    func test_partialObserver_implementedMethod_receivesRoute() {
        // given
        let partial = PartialObserverSpy()

        // when
        partial.didPush(route: AnyHashable("home"))

        // then
        XCTAssertEqual(partial.pushedRoute, AnyHashable("home"))
    }
}
