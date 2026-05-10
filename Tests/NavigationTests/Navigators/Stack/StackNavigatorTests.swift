//
//  StackNavigatorTests.swift
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

@available(iOS 16.0, *)
/// StackNavigator<Route>의 스택 상태 변경 동작을 검증하는 테스트입니다.
final class StackNavigatorTests: XCTestCase {

    // MARK: - Helpers

    @MainActor
    private func makeSUT() -> StackNavigator<TestRoute> {
        StackNavigator()
    }

    // MARK: - push

    @MainActor
    func test_push_appendsRouteToPath() {
        // given
        let sut = makeSUT()

        // when
        sut.push(.home)

        // then
        XCTAssertEqual(sut.path, [.home])
    }

    @MainActor
    func test_push_multipleCalls_appendsInOrder() {
        // given
        let sut = makeSUT()

        // when
        sut.push(.home)
        sut.push(.detail(id: "1"))
        sut.push(.settings)

        // then
        XCTAssertEqual(sut.path, [.home, .detail(id: "1"), .settings])
    }

    // MARK: - pop

    @MainActor
    func test_pop_removesLastRoute() {
        // given
        let sut = makeSUT()
        sut.push(.home)
        sut.push(.settings)

        // when
        sut.pop()

        // then
        XCTAssertEqual(sut.path, [.home])
    }

    @MainActor
    func test_pop_onEmptyStack_doesNotCrash() {
        // given
        let sut = makeSUT()

        // when
        sut.pop()

        // then
        XCTAssertTrue(sut.path.isEmpty)
    }

    // MARK: - popToRoot

    @MainActor
    func test_popToRoot_clearsEntirePath() {
        // given
        let sut = makeSUT()
        sut.push(.home)
        sut.push(.detail(id: "1"))
        sut.push(.settings)

        // when
        sut.popToRoot()

        // then
        XCTAssertTrue(sut.path.isEmpty)
    }

    // MARK: - replace

    @MainActor
    func test_replace_overwritesEntirePath() {
        // given
        let sut = makeSUT()
        sut.push(.home)
        sut.push(.settings)

        // when
        sut.replace(with: [.settings, .home, .detail(id: "1")])

        // then
        XCTAssertEqual(sut.path, [.settings, .home, .detail(id: "1")])
    }

    @MainActor
    func test_replace_withEmptyArray_clearsPath() {
        // given
        let sut = makeSUT()
        sut.push(.home)
        sut.push(.settings)

        // when
        sut.replace(with: [])

        // then
        XCTAssertTrue(sut.path.isEmpty)
    }

    // MARK: - pop(to:)

    @MainActor
    func test_popTo_removesRoutesAfterTarget() {
        // given
        let sut = makeSUT()
        sut.push(.home)
        sut.push(.detail(id: "1"))
        sut.push(.settings)

        // when
        sut.pop(to: .detail(id: "1"))

        // then
        XCTAssertEqual(sut.path, [.home, .detail(id: "1")])
    }

    @MainActor
    func test_popTo_usesLastOccurrenceWhenRouteDuplicated() {
        // given
        let sut = makeSUT()
        sut.push(.home)
        sut.push(.detail(id: "1"))
        sut.push(.home)

        // when
        sut.pop(to: .detail(id: "1"))

        // then
        XCTAssertEqual(sut.path, [.home, .detail(id: "1")])
    }

    @MainActor
    func test_popTo_missingRoute_doesNotModifyPath() {
        // given
        let sut = makeSUT()
        sut.push(.home)
        sut.push(.detail(id: "1"))

        // when
        sut.pop(to: .settings)

        // then
        XCTAssertEqual(sut.path, [.home, .detail(id: "1")])
    }

    // MARK: - present / dismiss

    @MainActor
    func test_present_sheet_setsRouteAndStyle() {
        // given
        let sut = makeSUT()

        // when
        sut.present(.settings, style: .sheet)

        // then
        XCTAssertEqual(sut.presentationItem?.route, .settings)
        XCTAssertEqual(sut.presentationItem?.style, .sheet)
    }

    @MainActor
    func test_present_fullScreenCover_setsRouteAndStyle() {
        // given
        let sut = makeSUT()

        // when
        sut.present(.home, style: .fullScreenCover)

        // then
        XCTAssertEqual(sut.presentationItem?.route, .home)
        XCTAssertEqual(sut.presentationItem?.style, .fullScreenCover)
    }

    @MainActor
    func test_present_sheetWithDetents_setsRouteAndStyle() {
        // given
        let sut = makeSUT()
        let detents: Set<NavigationDetent> = [.medium, .large]

        // when
        sut.present(.detail(id: "1"), style: .sheetWithDetents(detents))

        // then
        XCTAssertEqual(sut.presentationItem?.route, .detail(id: "1"))
        XCTAssertEqual(sut.presentationItem?.style, .sheetWithDetents(detents))
    }

    @MainActor
    func test_present_consecutiveCalls_replacesFirst() {
        // given
        let sut = makeSUT()
        sut.present(.home, style: .sheet)

        // when
        sut.present(.settings, style: .fullScreenCover)

        // then
        XCTAssertEqual(sut.presentationItem?.route, .settings)
        XCTAssertEqual(sut.presentationItem?.style, .fullScreenCover)
    }

    @MainActor
    func test_dismiss_clearsPresentationItem() {
        // given
        let sut = makeSUT()
        sut.present(.settings, style: .sheet)

        // when
        sut.dismiss()

        // then
        XCTAssertNil(sut.presentationItem)
    }
}
