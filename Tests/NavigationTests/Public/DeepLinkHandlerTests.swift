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

private struct StubDeepLinkHandler: DeepLinkHandlerProtocol {

    func canHandle(_ url: URL) -> Bool {
        url.host == "myapp.com"
    }

    func route(from url: URL) -> TestRoute? {
        switch url.path {
        case "/home":            return .home
        case "/settings":        return .settings
        default:
            if url.path.hasPrefix("/detail/") {
                let id = String(url.path.dropFirst("/detail/".count))
                return .detail(id: id)
            }
            return nil
        }
    }
}

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
        let url = URL(string: "https://myapp.com/home")!

        XCTAssertTrue(sut.canHandle(url))
    }

    func test_canHandle_returnsFalse_forUnknownHost() {
        let url = URL(string: "https://other.com/home")!

        XCTAssertFalse(sut.canHandle(url))
    }

    func test_canHandle_returnsFalse_forCustomScheme_withWrongHost() {
        let url = URL(string: "myapp://other.com/home")!

        XCTAssertFalse(sut.canHandle(url))
    }

    // MARK: - route(from:)

    func test_route_returnsHomeRoute_forHomePath() {
        let url = URL(string: "https://myapp.com/home")!

        XCTAssertEqual(sut.route(from: url), .home)
    }

    func test_route_returnsSettingsRoute_forSettingsPath() {
        let url = URL(string: "https://myapp.com/settings")!

        XCTAssertEqual(sut.route(from: url), .settings)
    }

    func test_route_returnsDetailRoute_withIdFromPath() {
        let url = URL(string: "https://myapp.com/detail/item-99")!

        XCTAssertEqual(sut.route(from: url), .detail(id: "item-99"))
    }

    func test_route_returnsNil_forUnknownPath() {
        let url = URL(string: "https://myapp.com/unknown")!

        XCTAssertNil(sut.route(from: url))
    }
}
