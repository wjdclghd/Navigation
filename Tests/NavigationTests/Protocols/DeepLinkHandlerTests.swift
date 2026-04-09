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

/*
 DeepLinkHandlerProtocol을 채택한 Stub 구현체입니다.

 호스트 기반 URL 처리 가능 여부 판단과 경로 기반 Route 변환 로직을 구현하여
 DeepLinkHandlerProtocol의 canHandle과 route 메서드 동작을 검증할 때 사용합니다.
 */
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

/*
 DeepLinkHandlerProtocol의 canHandle과 route(from:) 동작을 검증하는 테스트입니다.

 이 테스트는 StubDeepLinkHandler를 통해 올바른 호스트의 URL에서만 canHandle이 true를
 반환하는지, 그리고 각 URL 경로가 기대하는 Route로 변환되는지를 확인합니다.
 */
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

    /*
     유효한 호스트를 가진 URL에서 canHandle이 true를 반환하는지 검증합니다.
     */
    func test_canHandle_returnsTrue_forValidHost() {
        let url = URL(string: "https://myapp.com/home")!

        XCTAssertTrue(sut.canHandle(url))
    }

    /*
     알 수 없는 호스트를 가진 URL에서 canHandle이 false를 반환하는지 검증합니다.
     */
    func test_canHandle_returnsFalse_forUnknownHost() {
        let url = URL(string: "https://other.com/home")!

        XCTAssertFalse(sut.canHandle(url))
    }

    /*
     커스텀 스킴이더라도 호스트가 다르면 canHandle이 false를 반환하는지 검증합니다.
     */
    func test_canHandle_returnsFalse_forCustomScheme_withWrongHost() {
        let url = URL(string: "myapp://other.com/home")!

        XCTAssertFalse(sut.canHandle(url))
    }

    // MARK: - route(from:)

    /*
     /home 경로 URL이 home Route로 변환되는지 검증합니다.
     */
    func test_route_returnsHomeRoute_forHomePath() {
        let url = URL(string: "https://myapp.com/home")!

        XCTAssertEqual(sut.route(from: url), .home)
    }

    /*
     /settings 경로 URL이 settings Route로 변환되는지 검증합니다.
     */
    func test_route_returnsSettingsRoute_forSettingsPath() {
        let url = URL(string: "https://myapp.com/settings")!

        XCTAssertEqual(sut.route(from: url), .settings)
    }

    /*
     /detail/{id} 경로 URL에서 id가 포함된 detail Route로 변환되는지 검증합니다.
     */
    func test_route_returnsDetailRoute_withIdFromPath() {
        let url = URL(string: "https://myapp.com/detail/item-99")!

        XCTAssertEqual(sut.route(from: url), .detail(id: "item-99"))
    }

    /*
     알 수 없는 경로의 URL에서 route가 nil을 반환하는지 검증합니다.
     */
    func test_route_returnsNil_forUnknownPath() {
        let url = URL(string: "https://myapp.com/unknown")!

        XCTAssertNil(sut.route(from: url))
    }
}
