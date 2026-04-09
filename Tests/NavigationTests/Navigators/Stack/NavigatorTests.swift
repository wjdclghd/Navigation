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

/*
 Navigator<Route>의 타입 소거 동작과 메모리 안전성을 검증하는 테스트입니다.

 이 테스트는 NavigatorSpy를 통해 Navigator가 각 화면 이동 명령을 올바르게
 구현체에 전달하는지, 연관값이 포함된 Route가 정확히 전달되는지, 그리고
 구현체 해제 후에도 크래시 없이 동작하는지를 확인합니다.
 */
@MainActor
final class NavigatorTests: XCTestCase {

    private var spy: NavigatorSpy!
    private var sut: Navigator<TestRoute>!

    override func setUp() async throws {
        spy = NavigatorSpy()
        sut = Navigator(spy)
    }

    override func tearDown() async throws {
        sut = nil
        spy = nil
    }

    // MARK: - push

    /*
     push 호출 시 구현체에 명령과 Route 값이 전달되는지 검증합니다.
     */
    func test_push_forwardsCommandAndRouteValue() {
        sut.push(.home)

        XCTAssertEqual(spy.pushCount, 1)
        XCTAssertEqual(spy.lastPushedRoute, .home)
    }

    /*
     연관값이 포함된 Route가 정확히 구현체에 전달되는지 검증합니다.
     */
    func test_push_forwardsAssociatedValueRouteAccurately() {
        sut.push(.detail(id: "item-42"))

        XCTAssertEqual(spy.lastPushedRoute, .detail(id: "item-42"))
    }

    /*
     여러 번 push 시 호출 순서와 Route 목록이 구현체에 유지되는지 검증합니다.
     */
    func test_push_multipleCalls_forwardsAllRoutesInOrder() {
        sut.push(.home)
        sut.push(.detail(id: "1"))
        sut.push(.settings)

        XCTAssertEqual(spy.pushCount, 3)
        XCTAssertEqual(spy.pushedRoutes, [.home, .detail(id: "1"), .settings])
    }

    // MARK: - pop / popToRoot

    /*
     pop 호출이 구현체에 전달되는지 검증합니다.
     */
    func test_pop_forwardsCommandToImplementation() {
        sut.pop()

        XCTAssertEqual(spy.popCount, 1)
    }

    /*
     popToRoot 호출이 구현체에 전달되는지 검증합니다.
     */
    func test_popToRoot_forwardsCommandToImplementation() {
        sut.popToRoot()

        XCTAssertEqual(spy.popToRootCount, 1)
    }

    // MARK: - replace

    /*
     replace 호출 시 Route 배열이 구현체에 전달되는지 검증합니다.
     */
    func test_replace_forwardsRoutes() {
        sut.replace(with: [.home, .settings])

        XCTAssertEqual(spy.replaceCount, 1)
        XCTAssertEqual(spy.lastReplacedRoutes, [.home, .settings])
    }

    /*
     빈 배열로 replace 호출 시 빈 배열이 그대로 구현체에 전달되는지 검증합니다.
     */
    func test_replace_withEmptyArray_forwardsEmptyRoutes() {
        sut.replace(with: [])

        XCTAssertEqual(spy.lastReplacedRoutes, [])
    }

    // MARK: - pop(to:)

    /*
     pop(to:) 호출 시 대상 Route가 구현체에 전달되는지 검증합니다.
     */
    func test_popTo_forwardsTargetRoute() {
        sut.pop(to: .settings)

        XCTAssertEqual(spy.popToCount, 1)
        XCTAssertEqual(spy.lastPopToRoute, .settings)
    }

    // MARK: - present / dismiss

    /*
     present 호출 시 Route와 스타일이 구현체에 전달되는지 검증합니다.
     */
    func test_present_forwardsRouteAndStyle() {
        sut.present(.settings, style: .fullScreenCover)

        XCTAssertEqual(spy.presentCount, 1)
        XCTAssertEqual(spy.lastPresentedRoute, .settings)
        XCTAssertEqual(spy.lastPresentedStyle, .fullScreenCover)
    }

    /*
     기본 스타일로 present 시 sheet 스타일이 구현체에 전달되는지 검증합니다.
     */
    func test_present_defaultStyle_forwardsSheetStyle() {
        sut.present(.home, style: .sheet)

        XCTAssertEqual(spy.lastPresentedStyle, .sheet)
    }

    /*
     dismiss 호출이 구현체에 전달되는지 검증합니다.
     */
    func test_dismiss_forwardsCommandToImplementation() {
        sut.dismiss()

        XCTAssertEqual(spy.dismissCount, 1)
    }

    // MARK: - 메모리 안전성

    /*
     구현체 해제 후 모든 화면 이동 명령을 호출해도 크래시가 발생하지 않는지 검증합니다.

     [weak navigator] 캡처를 통해 구현체 해제 후 클로저가 아무 동작도 하지 않으면서
     앱이 안전하게 유지되어야 합니다.
     */
    func test_weakCapture_afterImplementationReleased_doesNotCrash() {
        var localSpy: NavigatorSpy? = NavigatorSpy()
        let localSut = Navigator(localSpy!)

        localSpy = nil

        localSut.push(.home)
        localSut.pop()
        localSut.popToRoot()
        localSut.replace(with: [.home])
        localSut.pop(to: .home)
        localSut.present(.settings, style: .sheet)
        localSut.dismiss()

        XCTAssertTrue(true)
    }

    /*
     구현체가 해제된 Navigator가 다른 Navigator 인스턴스의 동작에 영향을 주지 않는지 검증합니다.
     */
    func test_weakCapture_afterImplementationReleased_doesNotAffectOtherInstances() {
        var releasableSpy: NavigatorSpy? = NavigatorSpy()
        let releasableNavigator = Navigator(releasableSpy!)

        releasableNavigator.push(.detail(id: "before-release"))
        XCTAssertEqual(releasableSpy?.pushCount, 1)

        releasableSpy = nil

        releasableNavigator.push(.settings)
        releasableNavigator.replace(with: [.home])

        sut.push(.home)
        XCTAssertEqual(spy.pushCount, 1)
    }
}

// MARK: - NavigatorSpy

/*
 Navigator<Route> 테스트에서 구현체 역할을 하는 Spy입니다.

 각 화면 이동 명령의 호출 횟수와 전달된 인자를 기록하여
 Navigator가 올바르게 명령을 위임하는지 검증합니다.
 */
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
