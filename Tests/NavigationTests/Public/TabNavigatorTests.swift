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

@MainActor
final class TabNavigatorTests: XCTestCase {

    private var spy: TabNavigatorSpy!
    private var sut: TabNavigator<TestTab>!

    override func setUp() {
        super.setUp()
        spy = TabNavigatorSpy()
        sut = TabNavigator(spy)
    }

    override func tearDown() {
        sut = nil
        spy = nil
        super.tearDown()
    }

    // MARK: - select

    func test_select_forwardsTabToImplementation() {
        sut.select(.search)

        XCTAssertEqual(spy.selectedTab, .search)
    }

    func test_select_multipleCalls_lastOneWins() {
        sut.select(.search)
        sut.select(.myPage)

        XCTAssertEqual(spy.selectedTab, .myPage)
    }

    func test_select_recordsCallCount() {
        sut.select(.home)
        sut.select(.search)
        sut.select(.myPage)

        XCTAssertEqual(spy.selectCount, 3)
    }

    // MARK: - selectedTab

    func test_selectedTab_reflectsImplementationState() {
        spy.select(.myPage)

        XCTAssertEqual(sut.selectedTab, .myPage)
    }

    func test_selectedTab_afterMultipleSelects_returnsLastTab() {
        sut.select(.search)
        sut.select(.home)

        XCTAssertEqual(sut.selectedTab, .home)
        XCTAssertEqual(sut.selectedTab, spy.selectedTab)
    }

    // MARK: - 메모리 안전성

    func test_weakCapture_afterImplementationReleased_selectDoesNotCrash() {
        var localSpy: TabNavigatorSpy? = TabNavigatorSpy()
        let localSut = TabNavigator(localSpy!)

        localSpy = nil

        localSut.select(.search)

        XCTAssertTrue(true)
    }
}

// MARK: - TabNavigatorSpy

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
