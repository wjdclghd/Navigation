//
//  DeepLinkHandlerProtocol.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Foundation

/// 딥링크 URL을 Route로 변환하는 처리기 프로토콜입니다.
///
/// URL 수신과 변환된 Route 연결은 호출부가 담당하고, 이 계약은 URL 처리 가능 여부와 변환만 표현합니다.
public protocol DeepLinkHandlerProtocol: Sendable {
    associatedtype Route: Hashable

    /// 주어진 URL을 이 핸들러가 처리할 수 있는지 확인합니다.
    ///
    /// - Parameter url: 처리 여부를 확인할 URL입니다.
    /// - Returns: 처리 가능하면 `true`, 그렇지 않으면 `false`입니다.
    func canHandle(_ url: URL) -> Bool

    /// URL을 Route로 변환합니다.
    ///
    /// `canHandle(_:)`이 `true`인 URL에 대해 호출하는 것을 권장합니다.
    ///
    /// - Parameter url: Route로 변환할 URL입니다.
    /// - Returns: 변환된 Route 값입니다. 변환할 수 없으면 `nil`을 반환합니다.
    func route(from url: URL) -> Route?
}
