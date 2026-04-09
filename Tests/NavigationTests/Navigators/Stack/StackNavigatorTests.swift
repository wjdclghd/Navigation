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

/*
 StackNavigator<Route>의 스택 상태 변경 동작을 검증하는 테스트입니다.

 이 테스트는 push, pop, popToRoot, replace, pop(to:), present, dismiss가
 path 및 presentationItem 상태를 올바르게 변경하는지,
 그리고 경계 조건(빈 스택, 존재하지 않는 Route)에서 안전하게 동작하는지를 확인합니다.
 */
@available(iOS 16.0, *)
@MainActor
final class StackNavigatorTests: XCTestCase {

    private var sut: StackNavigator<TestRoute>!

    override func setUp() async throws {
        sut = StackNavigator()
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
     중복된 Route가 있을 때 pop(to:)가 마지막 위치를 기준으로 동작하는지 검증합니다.
     */
    func test_popTo_usesLastOccurrenceWhenRouteDuplicated() {
        sut.push(.home)
        sut.push(.detail(id: "1"))
        sut.push(.home)

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
     detents가 포함된 sheet 스타일로 present 시 Route와 스타일이 정확히 설정되는지 검증합니다.
     */
    func test_present_sheetWithDetents_setsRouteAndStyle() {
        let detents: Set<NavigationDetent> = [.medium, .large]

        sut.present(.detail(id: "1"), style: .sheetWithDetents(detents))

        XCTAssertEqual(sut.presentationItem?.route, .detail(id: "1"))
        XCTAssertEqual(sut.presentationItem?.style, .sheetWithDetents(detents))
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
