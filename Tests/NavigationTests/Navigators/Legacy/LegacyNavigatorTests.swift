//
//  LegacyNavigatorTests.swift
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

/// LegacyNavigator<Route>의 클로저 위임 동작을 검증하는 테스트입니다.
@available(iOS, deprecated: 16.0)
final class LegacyNavigatorTests: XCTestCase {

    // MARK: - Helpers

    @MainActor
    private func makeSUT(
        push: @escaping (TestRoute) -> Void = { _ in },
        pop: @escaping () -> Void = {},
        popToRoot: @escaping () -> Void = {},
        replace: @escaping ([TestRoute]) -> Void = { _ in },
        popTo: @escaping (TestRoute) -> Void = { _ in },
        present: @escaping (TestRoute, PresentationStyle) -> Void = { _, _ in },
        dismiss: @escaping () -> Void = {}
    ) -> LegacyNavigator<TestRoute> {
        LegacyNavigator(
            push: push,
            pop: pop,
            popToRoot: popToRoot,
            replace: replace,
            popTo: popTo,
            present: present,
            dismiss: dismiss
        )
    }

    // MARK: - push

    @MainActor
    func test_push_invokesHandler() {
        // given
        var receivedRoute: TestRoute?
        let sut = makeSUT(push: { receivedRoute = $0 })

        // when
        sut.push(.detail(id: "42"))

        // then
        XCTAssertEqual(receivedRoute, .detail(id: "42"))
    }

    // MARK: - pop

    @MainActor
    func test_pop_invokesHandler() {
        // given
        var popCount = 0
        let sut = makeSUT(pop: { popCount += 1 })

        // when
        sut.pop()

        // then
        XCTAssertEqual(popCount, 1)
    }

    // MARK: - popToRoot

    @MainActor
    func test_popToRoot_invokesHandler() {
        // given
        var popToRootCount = 0
        let sut = makeSUT(popToRoot: { popToRootCount += 1 })

        // when
        sut.popToRoot()

        // then
        XCTAssertEqual(popToRootCount, 1)
    }

    // MARK: - replace

    @MainActor
    func test_replace_invokesHandlerWithRoutes() {
        // given
        var receivedRoutes: [TestRoute]?
        let sut = makeSUT(replace: { receivedRoutes = $0 })

        // when
        sut.replace(with: [.home, .settings])

        // then
        XCTAssertEqual(receivedRoutes, [.home, .settings])
    }

    // MARK: - pop(to:)

    @MainActor
    func test_popTo_invokesHandlerWithRoute() {
        // given
        var receivedRoute: TestRoute?
        let sut = makeSUT(popTo: { receivedRoute = $0 })

        // when
        sut.pop(to: .settings)

        // then
        XCTAssertEqual(receivedRoute, .settings)
    }

    // MARK: - present

    @MainActor
    func test_present_invokesHandlerWithRouteAndStyle() {
        // given
        var receivedRoute: TestRoute?
        var receivedStyle: PresentationStyle?
        let sut = makeSUT(present: { route, style in
            receivedRoute = route
            receivedStyle = style
        })

        // when
        sut.present(.settings, style: .fullScreenCover)

        // then
        XCTAssertEqual(receivedRoute, .settings)
        XCTAssertEqual(receivedStyle, .fullScreenCover)
    }

    // MARK: - dismiss

    @MainActor
    func test_dismiss_invokesHandler() {
        // given
        var dismissCount = 0
        let sut = makeSUT(dismiss: { dismissCount += 1 })

        // when
        sut.dismiss()

        // then
        XCTAssertEqual(dismissCount, 1)
    }

    // MARK: - 전체 명령 순서

    @MainActor
    func test_allCommands_invokeCorrectHandlersInOrder() {
        // given
        var pushCount      = 0
        var popCount       = 0
        var popToRootCount = 0
        var replaceCount   = 0
        var popToCount     = 0
        var presentCount   = 0
        var dismissCount   = 0

        let sut = makeSUT(
            push: { _ in pushCount += 1 },
            pop: { popCount += 1 },
            popToRoot: { popToRootCount += 1 },
            replace: { _ in replaceCount += 1 },
            popTo: { _ in popToCount += 1 },
            present: { _, _ in presentCount += 1 },
            dismiss: { dismissCount += 1 }
        )

        // when
        sut.push(.home)
        sut.present(.settings, style: .sheet)
        sut.pop()
        sut.popToRoot()
        sut.replace(with: [.home])
        sut.pop(to: .home)
        sut.dismiss()

        // then
        XCTAssertEqual(pushCount,      1)
        XCTAssertEqual(presentCount,   1)
        XCTAssertEqual(popCount,       1)
        XCTAssertEqual(popToRootCount, 1)
        XCTAssertEqual(replaceCount,   1)
        XCTAssertEqual(popToCount,     1)
        XCTAssertEqual(dismissCount,   1)
    }
}
