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

/// TabNavigator<Tab>의 타입 소거 동작과 메모리 안전성을 검증하는 테스트입니다.
final class TabNavigatorTests: XCTestCase {

    // MARK: - Helpers

    @MainActor
    private func makeSUT() -> (sut: TabNavigator<TestTab>, spy: TabNavigatorSpy) {
        let spy = TabNavigatorSpy()
        let sut = TabNavigator(spy)
        return (sut, spy)
    }

    // MARK: - select

    @MainActor
    func test_select_forwardsTabToImplementation() {
        // given
        let (sut, spy) = makeSUT()

        // when
        sut.select(.search)

        // then
        XCTAssertEqual(spy.selectedTab, .search)
    }

    @MainActor
    func test_select_multipleCalls_lastOneWins() {
        // given
        let (sut, spy) = makeSUT()

        // when
        sut.select(.search)
        sut.select(.myPage)

        // then
        XCTAssertEqual(spy.selectedTab, .myPage)
    }

    @MainActor
    func test_select_recordsCallCount() {
        // given
        let (sut, spy) = makeSUT()

        // when
        sut.select(.home)
        sut.select(.search)
        sut.select(.myPage)

        // then
        XCTAssertEqual(spy.selectCount, 3)
    }

    @MainActor
    func test_select_notifiesObserverWithSelectedTab() {
        // given
        let (sut, _) = makeSUT()
        let observer = TabObserverSpy()
        sut.addObserver(observer)

        // when
        sut.select(.search)

        // then
        XCTAssertEqual(observer.selectedTabs, [AnyHashable(TestTab.search)])
    }

    @MainActor
    func test_addObserver_whenSameInstanceAddedTwice_notifiesOnce() {
        // given
        let (sut, _) = makeSUT()
        let observer = TabObserverSpy()
        sut.addObserver(observer)
        sut.addObserver(observer)

        // when
        sut.select(.myPage)

        // then
        XCTAssertEqual(observer.selectedTabs, [AnyHashable(TestTab.myPage)])
    }

    @MainActor
    func test_removeObserver_stopsNotification() {
        // given
        let (sut, _) = makeSUT()
        let observer = TabObserverSpy()
        sut.addObserver(observer)
        sut.removeObserver(observer)

        // when
        sut.select(.search)

        // then
        XCTAssertTrue(observer.selectedTabs.isEmpty)
    }

    // MARK: - selectedTab

    @MainActor
    func test_selectedTab_reflectsImplementationState() {
        // given
        let (sut, spy) = makeSUT()

        // when
        spy.select(.myPage)

        // then
        XCTAssertEqual(sut.selectedTab, .myPage)
    }

    @MainActor
    func test_selectedTab_afterMultipleSelects_returnsLastTab() {
        // given
        let (sut, spy) = makeSUT()

        // when
        sut.select(.search)
        sut.select(.home)

        // then
        XCTAssertEqual(sut.selectedTab, .home)
        XCTAssertEqual(sut.selectedTab, spy.selectedTab)
    }

    // MARK: - 메모리 안전성

    @MainActor
    func test_weakCapture_afterImplementationReleased_selectDoesNotCrash() {
        // given
        var localSpy: TabNavigatorSpy? = TabNavigatorSpy()
        let localSut = TabNavigator(localSpy!)

        // when
        localSpy = nil
        localSut.select(.search)

        // then
        XCTAssertTrue(true)
    }

    @MainActor
    func test_weakCapture_afterImplementationReleased_selectedTabReturnsFallback() {
        // given
        var localSpy: TabNavigatorSpy? = TabNavigatorSpy()
        let localSut = TabNavigator(localSpy!)
        localSut.select(.myPage)

        // when
        localSpy = nil

        // then
        XCTAssertEqual(localSut.selectedTab, .myPage)
    }

    @MainActor
    func test_weakCapture_afterImplementationReleased_subsequentSelectUpdatesFallback() {
        // given
        var localSpy: TabNavigatorSpy? = TabNavigatorSpy()
        let localSut = TabNavigator(localSpy!)
        localSut.select(.search)
        localSpy = nil

        // when
        localSut.select(.myPage)

        // then
        XCTAssertEqual(localSut.selectedTab, .myPage)
    }
}

// MARK: - TabNavigatorSpy

/// TabNavigator<Tab> 테스트에서 구현체 역할을 하는 Spy입니다.
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

// MARK: - TabObserverSpy

/// TabNavigator<Tab> 테스트에서 탭 선택 이벤트를 기록하는 Spy입니다.
@MainActor
private final class TabObserverSpy: NavigationEventObserverProtocol {
    private(set) var selectedTabs: [AnyHashable] = []

    func didSelectTab(tab: AnyHashable) {
        selectedTabs.append(tab)
    }
}
