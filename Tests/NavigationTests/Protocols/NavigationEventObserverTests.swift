//
//  NavigationEventObserverTests.swift
//  NavigationTests
//
//  Created by jch on 2/11/26.
//

import XCTest
@testable import Navigation

// MARK: - FullObserverSpy

/*
 NavigationEventObserverProtocol의 모든 메서드를 구현한 Spy입니다.

 각 이벤트 메서드의 호출 여부와 전달된 인자를 기록하여
 옵저버가 올바른 이벤트를 수신하는지 검증합니다.
 */
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

/*
 NavigationEventObserverProtocol에서 didPush만 구현한 Spy입니다.

 default extension이 제공하는 선택적 구현이 누락된 메서드에서
 크래시 없이 동작하는지 검증합니다.
 */
@MainActor
private final class PartialObserverSpy: NavigationEventObserverProtocol {
    private(set) var pushedRoute: AnyHashable?
    func didPush(route: AnyHashable) { pushedRoute = route }
}

// MARK: - Tests

/*
 NavigationEventObserverProtocol의 이벤트 수신 동작과 default extension을 검증하는 테스트입니다.

 이 테스트는 모든 메서드를 구현한 FullObserverSpy를 통해 각 이벤트가 올바른 인자와 함께
 전달되는지 확인하고, PartialObserverSpy를 통해 default extension이 미구현 메서드를
 안전하게 처리하는지를 검증합니다.
 */
@MainActor
final class NavigationEventObserverProtocolTests: XCTestCase {

    private var sut: FullObserverSpy!

    override func setUp() async throws {
        sut = FullObserverSpy()
    }

    override func tearDown() async throws {
        sut = nil
    }

    // MARK: - 전체 구현 옵저버

    /*
     didPush 호출 시 전달된 Route가 정확히 수신되는지 검증합니다.
     */
    func test_didPush_receivesRoute() {
        sut.didPush(route: AnyHashable("home"))

        XCTAssertEqual(sut.pushedRoute, AnyHashable("home"))
    }

    /*
     didPop을 여러 번 호출했을 때 카운트가 정확히 증가하는지 검증합니다.
     */
    func test_didPop_incrementsCount() {
        sut.didPop()
        sut.didPop()

        XCTAssertEqual(sut.popCount, 2)
    }

    /*
     didPopToRoot 호출 시 카운트가 증가하는지 검증합니다.
     */
    func test_didPopToRoot_incrementsCount() {
        sut.didPopToRoot()

        XCTAssertEqual(sut.popToRootCount, 1)
    }

    /*
     didReplace 호출 시 전달된 Route 배열이 정확히 수신되는지 검증합니다.
     */
    func test_didReplace_receivesRoutes() {
        let routes: [AnyHashable] = [AnyHashable("home"), AnyHashable("settings")]

        sut.didReplace(with: routes)

        XCTAssertEqual(sut.replacedRoutes, routes)
    }

    /*
     didPopTo 호출 시 전달된 Route가 정확히 수신되는지 검증합니다.
     */
    func test_didPopTo_receivesRoute() {
        sut.didPopTo(route: AnyHashable("detail"))

        XCTAssertEqual(sut.popToRoute, AnyHashable("detail"))
    }

    /*
     didPresent 호출 시 Route와 스타일이 정확히 수신되는지 검증합니다.
     */
    func test_didPresent_receivesRouteAndStyle() {
        sut.didPresent(route: AnyHashable("settings"), style: .fullScreenCover)

        XCTAssertEqual(sut.presentedRoute, AnyHashable("settings"))
        XCTAssertEqual(sut.presentedStyle, .fullScreenCover)
    }

    /*
     didDismiss 호출 시 카운트가 증가하는지 검증합니다.
     */
    func test_didDismiss_incrementsCount() {
        sut.didDismiss()

        XCTAssertEqual(sut.dismissCount, 1)
    }

    /*
     didSelectTab 호출 시 전달된 탭이 정확히 수신되는지 검증합니다.
     */
    func test_didSelectTab_receivesTab() {
        sut.didSelectTab(tab: AnyHashable(1))

        XCTAssertEqual(sut.selectedTab, AnyHashable(1))
    }

    // MARK: - default extension 선택적 구현 검증

    /*
     didPush 이외의 메서드를 구현하지 않은 옵저버에서 모든 이벤트가 크래시 없이 처리되는지 검증합니다.

     default extension이 미구현 메서드에 빈 기본 구현을 제공하므로,
     필요한 이벤트만 선택적으로 구현해도 안전하게 동작해야 합니다.
     */
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

    /*
     직접 구현한 메서드는 default extension이 아닌 실제 구현이 호출되는지 검증합니다.
     */
    func test_partialObserver_implementedMethod_receivesRoute() {
        let partial = PartialObserverSpy()

        partial.didPush(route: AnyHashable("home"))

        XCTAssertEqual(partial.pushedRoute, AnyHashable("home"))
    }
}
