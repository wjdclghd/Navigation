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
@MainActor
final class StackNavigatorTests: XCTestCase {

    private var sut: StackNavigator<TestRoute>!

    override func setUp() {
        super.setUp()
        sut = StackNavigator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - push

    func test_push_appendsRouteToPath() {
        sut.push(.home)

        XCTAssertEqual(sut.path, [.home])
    }

    func test_push_multipleCalls_appendsInOrder() {
        sut.push(.home)
        sut.push(.detail(id: "1"))
        sut.push(.settings)

        XCTAssertEqual(sut.path, [.home, .detail(id: "1"), .settings])
    }

    // MARK: - pop

    func test_pop_removesLastRoute() {
        sut.push(.home)
        sut.push(.settings)

        sut.pop()

        XCTAssertEqual(sut.path, [.home])
    }

    func test_pop_onEmptyStack_doesNotCrash() {
        sut.pop()

        XCTAssertTrue(sut.path.isEmpty)
    }

    // MARK: - popToRoot

    func test_popToRoot_clearsEntirePath() {
        sut.push(.home)
        sut.push(.detail(id: "1"))
        sut.push(.settings)

        sut.popToRoot()

        XCTAssertTrue(sut.path.isEmpty)
    }

    // MARK: - present / dismiss

    func test_present_sheet_setsRouteAndStyle() {
        sut.present(.settings, style: .sheet)

        XCTAssertEqual(sut.presentationItem?.route, .settings)
        XCTAssertEqual(sut.presentationItem?.style, .sheet)
    }

    func test_present_fullScreenCover_setsRouteAndStyle() {
        sut.present(.home, style: .fullScreenCover)

        XCTAssertEqual(sut.presentationItem?.route, .home)
        XCTAssertEqual(sut.presentationItem?.style, .fullScreenCover)
    }

    func test_present_sheetWithDetents_setsRouteAndStyle() {
        let detents: Set<NavigationDetent> = [.medium, .large]

        sut.present(.detail(id: "1"), style: .sheetWithDetents(detents))

        XCTAssertEqual(sut.presentationItem?.route, .detail(id: "1"))
        XCTAssertEqual(sut.presentationItem?.style, .sheetWithDetents(detents))
    }

    func test_present_consecutiveCalls_replacesFirst() {
        sut.present(.home, style: .sheet)
        sut.present(.settings, style: .fullScreenCover)

        XCTAssertEqual(sut.presentationItem?.route, .settings)
        XCTAssertEqual(sut.presentationItem?.style, .fullScreenCover)
    }

    func test_dismiss_clearsPresentationItem() {
        sut.present(.settings, style: .sheet)

        sut.dismiss()

        XCTAssertNil(sut.presentationItem)
    }
}
