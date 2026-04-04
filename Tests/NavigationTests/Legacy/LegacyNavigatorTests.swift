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

    // MARK: - 핸들러 호출 전달

    func test_push_invokesHandler() {
        var receivedRoute: TestRoute?
        let sut = LegacyNavigator<TestRoute>(
            push:      { receivedRoute = $0 },
            pop:       {},
            popToRoot: {},
            present:   { _ in },
            dismiss:   {}
        )

        sut.push(.detail(id: "42"))

        XCTAssertEqual(receivedRoute, .detail(id: "42"))
    }

    func test_pop_invokesHandler() {
        var popCount = 0
        let sut = LegacyNavigator<TestRoute>(
            push:      { _ in },
            pop:       { popCount += 1 },
            popToRoot: {},
            present:   { _ in },
            dismiss:   {}
        )

        sut.pop()

        XCTAssertEqual(popCount, 1)
    }

    func test_popToRoot_invokesHandler() {
        var popToRootCount = 0
        let sut = LegacyNavigator<TestRoute>(
            push:      { _ in },
            pop:       {},
            popToRoot: { popToRootCount += 1 },
            present:   { _ in },
            dismiss:   {}
        )

        sut.popToRoot()

        XCTAssertEqual(popToRootCount, 1)
    }

    func test_present_invokesHandlerWithRoute() {
        var receivedRoute: TestRoute?
        let sut = LegacyNavigator<TestRoute>(
            push:      { _ in },
            pop:       {},
            popToRoot: {},
            present:   { receivedRoute = $0 },
            dismiss:   {}
        )

        sut.present(.settings)

        XCTAssertEqual(receivedRoute, .settings)
    }

    func test_dismiss_invokesHandler() {
        var dismissCount = 0
        let sut = LegacyNavigator<TestRoute>(
            push:      { _ in },
            pop:       {},
            popToRoot: {},
            present:   { _ in },
            dismiss:   { dismissCount += 1 }
        )

        sut.dismiss()

        XCTAssertEqual(dismissCount, 1)
    }

    // MARK: - 전체 명령 순서

    func test_allCommands_invokeCorrectHandlersInOrder() {
        var pushCount     = 0
        var popCount      = 0
        var popToRootCount = 0
        var presentCount  = 0
        var dismissCount  = 0

        let sut = LegacyNavigator<TestRoute>(
            push:      { _ in pushCount += 1 },
            pop:       { popCount += 1 },
            popToRoot: { popToRootCount += 1 },
            present:   { _ in presentCount += 1 },
            dismiss:   { dismissCount += 1 }
        )

        sut.push(.home)
        sut.present(.settings)
        sut.pop()
        sut.popToRoot()
        sut.dismiss()

        XCTAssertEqual(pushCount,      1)
        XCTAssertEqual(presentCount,   1)
        XCTAssertEqual(popCount,       1)
        XCTAssertEqual(popToRootCount, 1)
        XCTAssertEqual(dismissCount,   1)
    }
}
