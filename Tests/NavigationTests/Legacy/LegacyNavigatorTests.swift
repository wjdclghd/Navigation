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

@MainActor
final class LegacyNavigatorTests: XCTestCase {

    // MARK: - 헬퍼

    private func makeSUT(
        push:      @escaping (TestRoute) -> Void          = { _ in },
        pop:       @escaping () -> Void                   = {},
        popToRoot: @escaping () -> Void                   = {},
        replace:   @escaping ([TestRoute]) -> Void        = { _ in },
        popTo:     @escaping (TestRoute) -> Void          = { _ in },
        present:   @escaping (TestRoute, PresentationStyle) -> Void = { _, _ in },
        dismiss:   @escaping () -> Void                   = {}
    ) -> LegacyNavigator<TestRoute> {
        LegacyNavigator(
            push:      push,
            pop:       pop,
            popToRoot: popToRoot,
            replace:   replace,
            popTo:     popTo,
            present:   present,
            dismiss:   dismiss
        )
    }

    // MARK: - push

    func test_push_invokesHandler() {
        var receivedRoute: TestRoute?
        let sut = makeSUT(push: { receivedRoute = $0 })

        sut.push(.detail(id: "42"))

        XCTAssertEqual(receivedRoute, .detail(id: "42"))
    }

    // MARK: - pop

    func test_pop_invokesHandler() {
        var popCount = 0
        let sut = makeSUT(pop: { popCount += 1 })

        sut.pop()

        XCTAssertEqual(popCount, 1)
    }

    // MARK: - popToRoot

    func test_popToRoot_invokesHandler() {
        var popToRootCount = 0
        let sut = makeSUT(popToRoot: { popToRootCount += 1 })

        sut.popToRoot()

        XCTAssertEqual(popToRootCount, 1)
    }

    // MARK: - replace

    func test_replace_invokesHandlerWithRoutes() {
        var receivedRoutes: [TestRoute]?
        let sut = makeSUT(replace: { receivedRoutes = $0 })

        sut.replace(with: [.home, .settings])

        XCTAssertEqual(receivedRoutes, [.home, .settings])
    }

    // MARK: - pop(to:)

    func test_popTo_invokesHandlerWithRoute() {
        var receivedRoute: TestRoute?
        let sut = makeSUT(popTo: { receivedRoute = $0 })

        sut.pop(to: .settings)

        XCTAssertEqual(receivedRoute, .settings)
    }

    // MARK: - present

    func test_present_invokesHandlerWithRouteAndStyle() {
        var receivedRoute: TestRoute?
        var receivedStyle: PresentationStyle?
        let sut = makeSUT(present: { route, style in
            receivedRoute = route
            receivedStyle = style
        })

        sut.present(.settings, style: .fullScreenCover)

        XCTAssertEqual(receivedRoute, .settings)
        XCTAssertEqual(receivedStyle, .fullScreenCover)
    }

    // MARK: - dismiss

    func test_dismiss_invokesHandler() {
        var dismissCount = 0
        let sut = makeSUT(dismiss: { dismissCount += 1 })

        sut.dismiss()

        XCTAssertEqual(dismissCount, 1)
    }

    // MARK: - 전체 명령 순서

    func test_allCommands_invokeCorrectHandlersInOrder() {
        var pushCount      = 0
        var popCount       = 0
        var popToRootCount = 0
        var replaceCount   = 0
        var popToCount     = 0
        var presentCount   = 0
        var dismissCount   = 0

        let sut = makeSUT(
            push:      { _ in pushCount += 1 },
            pop:       { popCount += 1 },
            popToRoot: { popToRootCount += 1 },
            replace:   { _ in replaceCount += 1 },
            popTo:     { _ in popToCount += 1 },
            present:   { _, _ in presentCount += 1 },
            dismiss:   { dismissCount += 1 }
        )

        sut.push(.home)
        sut.present(.settings, style: .sheet)
        sut.pop()
        sut.popToRoot()
        sut.replace(with: [.home])
        sut.pop(to: .home)
        sut.dismiss()

        XCTAssertEqual(pushCount,      1)
        XCTAssertEqual(presentCount,   1)
        XCTAssertEqual(popCount,       1)
        XCTAssertEqual(popToRootCount, 1)
        XCTAssertEqual(replaceCount,   1)
        XCTAssertEqual(popToCount,     1)
        XCTAssertEqual(dismissCount,   1)
    }
}
