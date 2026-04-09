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

/*
 LegacyNavigator<Route>의 클로저 위임 동작을 검증하는 테스트입니다.

 이 테스트는 LegacyNavigator가 각 화면 이동 명령을 주입된 클로저로 올바르게
 전달하는지, 모든 명령이 독립적으로 해당 핸들러를 호출하는지를 확인합니다.
 setUp/tearDown이 없으며 각 테스트에서 makeSUT 헬퍼를 통해 독립적인 인스턴스를 생성합니다.
 */
@available(iOS, deprecated: 16.0)
@MainActor
final class LegacyNavigatorTests: XCTestCase {

    // MARK: - 헬퍼

    /*
     테스트용 LegacyNavigator 인스턴스를 생성하는 헬퍼입니다.

     기본값으로 아무 동작도 하지 않는 클로저를 사용하므로,
     검증이 필요한 클로저만 개별 테스트에서 선택적으로 전달합니다.

     Parameters:
     - push:      push 명령을 수신할 클로저 (기본값: 빈 클로저)
     - pop:       pop 명령을 수신할 클로저 (기본값: 빈 클로저)
     - popToRoot: popToRoot 명령을 수신할 클로저 (기본값: 빈 클로저)
     - replace:   replace 명령을 수신할 클로저 (기본값: 빈 클로저)
     - popTo:     popTo 명령을 수신할 클로저 (기본값: 빈 클로저)
     - present:   present 명령을 수신할 클로저 (기본값: 빈 클로저)
     - dismiss:   dismiss 명령을 수신할 클로저 (기본값: 빈 클로저)

     Returns:
     - 테스트 목적으로 구성된 LegacyNavigator<TestRoute> 인스턴스
     */
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

    /*
     push 호출 시 주입된 핸들러가 Route와 함께 호출되는지 검증합니다.
     */
    func test_push_invokesHandler() {
        var receivedRoute: TestRoute?
        let sut = makeSUT(push: { receivedRoute = $0 })

        sut.push(.detail(id: "42"))

        XCTAssertEqual(receivedRoute, .detail(id: "42"))
    }

    // MARK: - pop

    /*
     pop 호출 시 주입된 핸들러가 호출되는지 검증합니다.
     */
    func test_pop_invokesHandler() {
        var popCount = 0
        let sut = makeSUT(pop: { popCount += 1 })

        sut.pop()

        XCTAssertEqual(popCount, 1)
    }

    // MARK: - popToRoot

    /*
     popToRoot 호출 시 주입된 핸들러가 호출되는지 검증합니다.
     */
    func test_popToRoot_invokesHandler() {
        var popToRootCount = 0
        let sut = makeSUT(popToRoot: { popToRootCount += 1 })

        sut.popToRoot()

        XCTAssertEqual(popToRootCount, 1)
    }

    // MARK: - replace

    /*
     replace 호출 시 주입된 핸들러가 Route 배열과 함께 호출되는지 검증합니다.
     */
    func test_replace_invokesHandlerWithRoutes() {
        var receivedRoutes: [TestRoute]?
        let sut = makeSUT(replace: { receivedRoutes = $0 })

        sut.replace(with: [.home, .settings])

        XCTAssertEqual(receivedRoutes, [.home, .settings])
    }

    // MARK: - pop(to:)

    /*
     pop(to:) 호출 시 주입된 핸들러가 대상 Route와 함께 호출되는지 검증합니다.
     */
    func test_popTo_invokesHandlerWithRoute() {
        var receivedRoute: TestRoute?
        let sut = makeSUT(popTo: { receivedRoute = $0 })

        sut.pop(to: .settings)

        XCTAssertEqual(receivedRoute, .settings)
    }

    // MARK: - present

    /*
     present 호출 시 주입된 핸들러가 Route와 스타일과 함께 호출되는지 검증합니다.
     */
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

    /*
     dismiss 호출 시 주입된 핸들러가 호출되는지 검증합니다.
     */
    func test_dismiss_invokesHandler() {
        var dismissCount = 0
        let sut = makeSUT(dismiss: { dismissCount += 1 })

        sut.dismiss()

        XCTAssertEqual(dismissCount, 1)
    }

    // MARK: - 전체 명령 순서

    /*
     모든 화면 이동 명령을 순서대로 호출했을 때 각 핸들러가 정확히 한 번씩 호출되는지 검증합니다.

     여러 핸들러를 동시에 주입한 환경에서 서로 간섭 없이 독립적으로 동작해야 합니다.
     */
    func test_allCommands_invokeCorrectHandlersInOrder() {
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
