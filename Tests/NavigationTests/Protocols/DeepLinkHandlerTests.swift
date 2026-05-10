//
//  DeepLinkHandlerTests.swift
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

/// DeepLinkHandlerProtocol을 채택한 Stub 구현체입니다.
private struct StubDeepLinkHandler: DeepLinkHandlerProtocol {

    func canHandle(_ url: URL) -> Bool {
        url.host == "myapp.com"
    }

    func route(from url: URL) -> TestRoute? {
        switch url.path {
        case "/home":
            return .home
        case "/settings":
            return .settings
        default:
            if url.path.hasPrefix("/detail/") {
                let id = String(url.path.dropFirst("/detail/".count))
                return .detail(id: id)
            }
            return nil
        }
    }
}

/// DeepLinkHandlerProtocol의 canHandle과 route(from:) 동작을 검증하는 테스트입니다.
final class DeepLinkHandlerTests: XCTestCase {

    private var sut: StubDeepLinkHandler!

    override func setUp() {
        super.setUp()
        sut = StubDeepLinkHandler()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - canHandle

    func test_canHandle_returnsTrue_forValidHost() {
        // given
        let url = URL(string: "https://myapp.com/home")!

        // when / then
        XCTAssertTrue(sut.canHandle(url))
    }

    func test_canHandle_returnsFalse_forUnknownHost() {
        // given
        let url = URL(string: "https://other.com/home")!

        // when / then
        XCTAssertFalse(sut.canHandle(url))
    }

    func test_canHandle_returnsFalse_forCustomScheme_withWrongHost() {
        // given
        let url = URL(string: "myapp://other.com/home")!

        // when / then
        XCTAssertFalse(sut.canHandle(url))
    }

    // MARK: - route(from:)

    func test_route_returnsHomeRoute_forHomePath() {
        // given
        let url = URL(string: "https://myapp.com/home")!

        // when
        let result = sut.route(from: url)

        // then
        XCTAssertEqual(result, .home)
    }

    func test_route_returnsSettingsRoute_forSettingsPath() {
        // given
        let url = URL(string: "https://myapp.com/settings")!

        // when
        let result = sut.route(from: url)

        // then
        XCTAssertEqual(result, .settings)
    }

    func test_route_returnsDetailRoute_withIdFromPath() {
        // given
        let url = URL(string: "https://myapp.com/detail/item-99")!

        // when
        let result = sut.route(from: url)

        // then
        XCTAssertEqual(result, .detail(id: "item-99"))
    }

    func test_route_returnsNil_forUnknownPath() {
        // given
        let url = URL(string: "https://myapp.com/unknown")!

        // when
        let result = sut.route(from: url)

        // then
        XCTAssertNil(result)
    }
}
