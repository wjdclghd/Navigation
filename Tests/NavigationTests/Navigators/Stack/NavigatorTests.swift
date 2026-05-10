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

/// Navigator<Route>의 타입 소거 동작과 메모리 안전성을 검증하는 테스트입니다.
final class NavigatorTests: XCTestCase {

    // MARK: - Helpers

    @MainActor
    private func makeSUT() -> (sut: Navigator<TestRoute>, spy: NavigatorSpy) {
        let spy = NavigatorSpy()
        let sut = Navigator(spy)
        return (sut, spy)
    }

    // MARK: - push

    @MainActor
    func test_push_forwardsCommandAndRouteValue() {
        // given
        let (sut, spy) = makeSUT()

        // when
        sut.push(.home)

        // then
        XCTAssertEqual(spy.pushCount, 1)
        XCTAssertEqual(spy.lastPushedRoute, .home)
    }

    @MainActor
    func test_push_forwardsAssociatedValueRouteAccurately() {
        // given
        let (sut, spy) = makeSUT()

        // when
        sut.push(.detail(id: "item-42"))

        // then
        XCTAssertEqual(spy.lastPushedRoute, .detail(id: "item-42"))
    }

    @MainActor
    func test_push_multipleCalls_forwardsAllRoutesInOrder() {
        // given
        let (sut, spy) = makeSUT()

        // when
        sut.push(.home)
        sut.push(.detail(id: "1"))
        sut.push(.settings)

        // then
        XCTAssertEqual(spy.pushCount, 3)
        XCTAssertEqual(spy.pushedRoutes, [.home, .detail(id: "1"), .settings])
    }

    // MARK: - pop / popToRoot

    @MainActor
    func test_pop_forwardsCommandToImplementation() {
        // given
        let (sut, spy) = makeSUT()

        // when
        sut.pop()

        // then
        XCTAssertEqual(spy.popCount, 1)
    }

    @MainActor
    func test_popToRoot_forwardsCommandToImplementation() {
        // given
        let (sut, spy) = makeSUT()

        // when
        sut.popToRoot()

        // then
        XCTAssertEqual(spy.popToRootCount, 1)
    }

    // MARK: - replace

    @MainActor
    func test_replace_forwardsRoutes() {
        // given
        let (sut, spy) = makeSUT()

        // when
        sut.replace(with: [.home, .settings])

        // then
        XCTAssertEqual(spy.replaceCount, 1)
        XCTAssertEqual(spy.lastReplacedRoutes, [.home, .settings])
    }

    @MainActor
    func test_replace_withEmptyArray_forwardsEmptyRoutes() {
        // given
        let (sut, spy) = makeSUT()

        // when
        sut.replace(with: [])

        // then
        XCTAssertEqual(spy.lastReplacedRoutes, [])
    }

    // MARK: - pop(to:)

    @MainActor
    func test_popTo_forwardsTargetRoute() {
        // given
        let (sut, spy) = makeSUT()

        // when
        sut.pop(to: .settings)

        // then
        XCTAssertEqual(spy.popToCount, 1)
        XCTAssertEqual(spy.lastPopToRoute, .settings)
    }

    // MARK: - present / dismiss

    @MainActor
    func test_present_forwardsRouteAndStyle() {
        // given
        let (sut, spy) = makeSUT()

        // when
        sut.present(.settings, style: .fullScreenCover)

        // then
        XCTAssertEqual(spy.presentCount, 1)
        XCTAssertEqual(spy.lastPresentedRoute, .settings)
        XCTAssertEqual(spy.lastPresentedStyle, .fullScreenCover)
    }

    @MainActor
    func test_present_defaultStyle_forwardsSheetStyle() {
        // given
        let (sut, spy) = makeSUT()

        // when
        sut.present(.home, style: .sheet)

        // then
        XCTAssertEqual(spy.lastPresentedStyle, .sheet)
    }

    @MainActor
    func test_dismiss_forwardsCommandToImplementation() {
        // given
        let (sut, spy) = makeSUT()

        // when
        sut.dismiss()

        // then
        XCTAssertEqual(spy.dismissCount, 1)
    }

    // MARK: - 메모리 안전성

    @MainActor
    func test_weakCapture_afterImplementationReleased_doesNotCrash() {
        // given
        var localSpy: NavigatorSpy? = NavigatorSpy()
        let localSut = Navigator(localSpy!)

        // when
        localSpy = nil
        localSut.push(.home)
        localSut.pop()
        localSut.popToRoot()
        localSut.replace(with: [.home])
        localSut.pop(to: .home)
        localSut.present(.settings, style: .sheet)
        localSut.dismiss()

        // then
        XCTAssertTrue(true)
    }

    @MainActor
    func test_weakCapture_afterImplementationReleased_doesNotAffectOtherInstances() {
        // given
        var releasableSpy: NavigatorSpy? = NavigatorSpy()
        let releasableNavigator = Navigator(releasableSpy!)
        let (sut, spy) = makeSUT()

        // when
        releasableNavigator.push(.detail(id: "before-release"))
        releasableSpy = nil
        releasableNavigator.push(.settings)
        releasableNavigator.replace(with: [.home])
        sut.push(.home)

        // then
        XCTAssertEqual(spy.pushCount, 1)
    }
}

// MARK: - NavigatorSpy

/// Navigator<Route> 테스트에서 구현체 역할을 하는 Spy입니다.
@MainActor
private final class NavigatorSpy: NavigatorProtocol {

    typealias Route = TestRoute

    private(set) var pushCount:      Int = 0
    private(set) var popCount:       Int = 0
    private(set) var popToRootCount: Int = 0
    private(set) var replaceCount:   Int = 0
    private(set) var popToCount:     Int = 0
    private(set) var presentCount:   Int = 0
    private(set) var dismissCount:   Int = 0

    private(set) var pushedRoutes:       [TestRoute] = []
    var lastPushedRoute:     TestRoute?      { pushedRoutes.last }
    private(set) var lastReplacedRoutes: [TestRoute]?
    private(set) var lastPopToRoute:     TestRoute?
    private(set) var lastPresentedRoute: TestRoute?
    private(set) var lastPresentedStyle: PresentationStyle?

    func push(_ route: TestRoute) {
        pushCount += 1
        pushedRoutes.append(route)
    }

    func pop()       { popCount += 1 }
    func popToRoot() { popToRootCount += 1 }
    func dismiss()   { dismissCount += 1 }

    func replace(with routes: [TestRoute]) {
        replaceCount += 1
        lastReplacedRoutes = routes
    }

    func pop(to route: TestRoute) {
        popToCount += 1
        lastPopToRoute = route
    }

    func present(_ route: TestRoute, style: PresentationStyle) {
        presentCount += 1
        lastPresentedRoute = route
        lastPresentedStyle = style
    }
}
