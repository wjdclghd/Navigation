//
//  ObservableStackNavigatorTests.swift
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
 ObservableStackNavigator<Route>의 스택 상태 변경 동작을 검증하는 테스트입니다.

 이 테스트는 @Observable 기반 구현체가 StackNavigator와 동일한 화면 이동 로직을
 제공하는지 확인하며, push, pop, popToRoot, replace, pop(to:), present, dismiss의
 상태 변화를 검증합니다.
 */
@available(iOS 17.0, *)
@MainActor
final class ObservableStackNavigatorTests: XCTestCase {

    private var sut: ObservableStackNavigator<TestRoute>!

    override func setUp() async throws {
        sut = ObservableStackNavigator()
    }

    override func tearDown() async throws {
        sut = nil
    }

    // MARK: - push

    /*
     push 호출 시 Route가 path 끝에 추가되는지 검증합니다.
     */
    func test_push_appendsRouteToPath() {
        sut.push(.home)

        XCTAssertEqual(sut.path, [.home])
    }

    /*
     여러 번 push 시 Route가 호출 순서대로 path에 쌓이는지 검증합니다.
     */
    func test_push_multipleCalls_appendsInOrder() {
        sut.push(.home)
        sut.push(.detail(id: "1"))
        sut.push(.settings)

        XCTAssertEqual(sut.path, [.home, .detail(id: "1"), .settings])
    }

    // MARK: - pop

    /*
     pop 호출 시 path의 마지막 Route가 제거되는지 검증합니다.
     */
    func test_pop_removesLastRoute() {
        sut.push(.home)
        sut.push(.settings)

        sut.pop()

        XCTAssertEqual(sut.path, [.home])
    }

    /*
     빈 스택에서 pop을 호출해도 크래시가 발생하지 않는지 검증합니다.
     */
    func test_pop_onEmptyStack_doesNotCrash() {
        sut.pop()

        XCTAssertTrue(sut.path.isEmpty)
    }

    // MARK: - popToRoot

    /*
     popToRoot 호출 시 path 전체가 비워지는지 검증합니다.
     */
    func test_popToRoot_clearsEntirePath() {
        sut.push(.home)
        sut.push(.detail(id: "1"))
        sut.push(.settings)

        sut.popToRoot()

        XCTAssertTrue(sut.path.isEmpty)
    }

    // MARK: - replace

    /*
     replace 호출 시 기존 path가 새 Route 배열로 교체되는지 검증합니다.
     */
    func test_replace_overwritesEntirePath() {
        sut.push(.home)
        sut.push(.settings)

        sut.replace(with: [.settings, .home, .detail(id: "1")])

        XCTAssertEqual(sut.path, [.settings, .home, .detail(id: "1")])
    }

    /*
     빈 배열로 replace 호출 시 path가 비워지는지 검증합니다.
     */
    func test_replace_withEmptyArray_clearsPath() {
        sut.push(.home)
        sut.push(.settings)

        sut.replace(with: [])

        XCTAssertTrue(sut.path.isEmpty)
    }

    // MARK: - pop(to:)

    /*
     pop(to:) 호출 시 대상 Route 이후의 항목이 모두 제거되는지 검증합니다.
     */
    func test_popTo_removesRoutesAfterTarget() {
        sut.push(.home)
        sut.push(.detail(id: "1"))
        sut.push(.settings)

        sut.pop(to: .detail(id: "1"))

        XCTAssertEqual(sut.path, [.home, .detail(id: "1")])
    }

    /*
     존재하지 않는 Route로 pop(to:)를 호출해도 path가 변경되지 않는지 검증합니다.
     */
    func test_popTo_missingRoute_doesNotModifyPath() {
        sut.push(.home)
        sut.push(.detail(id: "1"))

        sut.pop(to: .settings)

        XCTAssertEqual(sut.path, [.home, .detail(id: "1")])
    }

    // MARK: - present / dismiss

    /*
     sheet 스타일로 present 시 presentationItem에 Route와 스타일이 설정되는지 검증합니다.
     */
    func test_present_sheet_setsRouteAndStyle() {
        sut.present(.settings, style: .sheet)

        XCTAssertEqual(sut.presentationItem?.route, .settings)
        XCTAssertEqual(sut.presentationItem?.style, .sheet)
    }

    /*
     fullScreenCover 스타일로 present 시 presentationItem에 Route와 스타일이 설정되는지 검증합니다.
     */
    func test_present_fullScreenCover_setsRouteAndStyle() {
        sut.present(.home, style: .fullScreenCover)

        XCTAssertEqual(sut.presentationItem?.route, .home)
        XCTAssertEqual(sut.presentationItem?.style, .fullScreenCover)
    }

    /*
     present를 연속으로 호출하면 마지막 호출이 presentationItem을 덮어쓰는지 검증합니다.
     */
    func test_present_consecutiveCalls_replacesFirst() {
        sut.present(.home, style: .sheet)
        sut.present(.settings, style: .fullScreenCover)

        XCTAssertEqual(sut.presentationItem?.route, .settings)
        XCTAssertEqual(sut.presentationItem?.style, .fullScreenCover)
    }

    /*
     dismiss 호출 시 presentationItem이 nil로 초기화되는지 검증합니다.
     */
    func test_dismiss_clearsPresentationItem() {
        sut.present(.settings, style: .sheet)

        sut.dismiss()

        XCTAssertNil(sut.presentationItem)
    }
}
