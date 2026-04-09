//
//  TabNavigatorTests.swift
//  NavigationTests
//
//  Created by jch on 2/11/26.
//

import XCTest
@testable import Navigation

private enum TestTab: Hashable {
    case home
    case search
    case myPage
}

/*
 TabNavigator<Tab>의 타입 소거 동작과 메모리 안전성을 검증하는 테스트입니다.

 이 테스트는 TabNavigatorSpy를 통해 TabNavigator가 탭 선택 명령을 올바르게
 구현체에 전달하는지, selectedTab이 구현체 상태를 정확히 반영하는지, 그리고
 구현체 해제 후에도 _lastKnownTab 폴백을 통해 크래시 없이 동작하는지를 확인합니다.
 */
@MainActor
final class TabNavigatorTests: XCTestCase {

    private var spy: TabNavigatorSpy!
    private var sut: TabNavigator<TestTab>!

    override func setUp() async throws {
        spy = TabNavigatorSpy()
        sut = TabNavigator(spy)
    }

    override func tearDown() async throws {
        sut = nil
        spy = nil
    }

    // MARK: - select

    /*
     select 호출 시 구현체의 selectedTab이 변경되는지 검증합니다.
     */
    func test_select_forwardsTabToImplementation() {
        sut.select(.search)

        XCTAssertEqual(spy.selectedTab, .search)
    }

    /*
     여러 번 select 시 마지막으로 선택한 탭이 반영되는지 검증합니다.
     */
    func test_select_multipleCalls_lastOneWins() {
        sut.select(.search)
        sut.select(.myPage)

        XCTAssertEqual(spy.selectedTab, .myPage)
    }

    /*
     여러 번 select 시 호출 횟수가 정확히 카운트되는지 검증합니다.
     */
    func test_select_recordsCallCount() {
        sut.select(.home)
        sut.select(.search)
        sut.select(.myPage)

        XCTAssertEqual(spy.selectCount, 3)
    }

    // MARK: - selectedTab

    /*
     구현체의 selectedTab이 변경되면 TabNavigator의 selectedTab에 반영되는지 검증합니다.
     */
    func test_selectedTab_reflectsImplementationState() {
        spy.select(.myPage)

        XCTAssertEqual(sut.selectedTab, .myPage)
    }

    /*
     select 후 TabNavigator의 selectedTab이 구현체와 동일한지 검증합니다.
     */
    func test_selectedTab_afterMultipleSelects_returnsLastTab() {
        sut.select(.search)
        sut.select(.home)

        XCTAssertEqual(sut.selectedTab, .home)
        XCTAssertEqual(sut.selectedTab, spy.selectedTab)
    }

    // MARK: - 메모리 안전성

    /*
     구현체 해제 후 select를 호출해도 크래시가 발생하지 않는지 검증합니다.

     [weak navigator] 캡처를 통해 구현체 해제 후 클로저가 아무 동작도 하지 않으면서
     앱이 안전하게 유지되어야 합니다.
     */
    func test_weakCapture_afterImplementationReleased_selectDoesNotCrash() {
        var localSpy: TabNavigatorSpy? = TabNavigatorSpy()
        let localSut = TabNavigator(localSpy!)

        localSpy = nil

        localSut.select(.search)

        XCTAssertTrue(true)
    }

    /*
     구현체 해제 후 selectedTab 접근 시 _lastKnownTab 폴백 값이 반환되는지 검증합니다.

     select 호출마다 _lastKnownTab이 갱신되므로, 마지막으로 선택한 탭이
     구현체 해제 후에도 안전하게 반환되어야 합니다.
     */
    func test_weakCapture_afterImplementationReleased_selectedTabReturnsFallback() {
        var localSpy: TabNavigatorSpy? = TabNavigatorSpy()
        let localSut = TabNavigator(localSpy!)

        localSut.select(.myPage)
        localSpy = nil

        XCTAssertEqual(localSut.selectedTab, .myPage)
    }

    /*
     구현체 해제 후 select를 추가 호출하면 _lastKnownTab이 갱신되는지 검증합니다.

     구현체가 없더라도 select 호출이 _lastKnownTab을 최신 값으로 유지합니다.
     */
    func test_weakCapture_afterImplementationReleased_subsequentSelectUpdatesFallback() {
        var localSpy: TabNavigatorSpy? = TabNavigatorSpy()
        let localSut = TabNavigator(localSpy!)

        localSut.select(.search)
        localSpy = nil

        localSut.select(.myPage)

        XCTAssertEqual(localSut.selectedTab, .myPage)
    }
}

// MARK: - TabNavigatorSpy

/*
 TabNavigator<Tab> 테스트에서 구현체 역할을 하는 Spy입니다.

 탭 선택 명령의 호출 횟수와 현재 selectedTab 값을 기록하여
 TabNavigator가 올바르게 명령을 위임하는지 검증합니다.
 */
@MainActor
private final class TabNavigatorSpy: TabNavigatorProtocol {

    typealias Tab = TestTab

    private(set) var selectedTab: TestTab = .home
    private(set) var selectCount: Int     = 0

    func select(_ tab: TestTab) {
        selectedTab  = tab
        selectCount += 1
    }
}
