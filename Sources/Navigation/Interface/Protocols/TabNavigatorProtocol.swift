//
//  TabNavigatorProtocol.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

/// 탭바 기반 화면 전환을 추상화하는 프로토콜입니다.
///
/// Feature 모듈은 이 계약을 통해 탭을 전환하고 구체 구현체를 직접 알지 않습니다.
@MainActor
public protocol TabNavigatorProtocol: AnyObject, Sendable {
    associatedtype Tab: Hashable

    /// 현재 선택된 탭입니다.
    var selectedTab: Tab { get }

    /// 지정한 탭으로 전환합니다.
    ///
    /// - Parameter tab: 전환할 대상 탭입니다.
    func select(_ tab: Tab)
}
