//
//  NavigationEventObserverProtocol.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Foundation

/// 화면 이동 이벤트를 수신하는 옵저버 프로토콜입니다.
///
/// Analytics, 로깅, 화면 이동 추적처럼 이동 이벤트를 관찰해야 하는 호출부에서 사용합니다.
@MainActor
public protocol NavigationEventObserverProtocol: AnyObject, Sendable {

    /// `push` 이벤트가 발생했을 때 호출됩니다.
    func didPush(route: AnyHashable)

    /// `pop` 이벤트가 발생했을 때 호출됩니다.
    func didPop()

    /// `popToRoot` 이벤트가 발생했을 때 호출됩니다.
    func didPopToRoot()

    /// `replace` 이벤트가 발생했을 때 호출됩니다.
    ///
    /// - Parameter routes: 새로 구성된 스택의 Route 배열입니다.
    func didReplace(with routes: [AnyHashable])

    /// `pop(to:)` 이벤트가 발생했을 때 호출됩니다.
    ///
    /// - Parameter route: 되돌아간 대상 Route입니다.
    func didPopTo(route: AnyHashable)

    /// `present` 이벤트가 발생했을 때 호출됩니다.
    ///
    /// - Parameters:
    ///   - route: 표시된 화면의 Route입니다.
    ///   - style: 사용된 표시 방식입니다.
    func didPresent(route: AnyHashable, style: PresentationStyle)

    /// `dismiss` 이벤트가 발생했을 때 호출됩니다.
    func didDismiss()

    /// 탭 전환 이벤트가 발생했을 때 호출됩니다.
    ///
    /// - Parameter tab: 전환된 대상 탭입니다.
    func didSelectTab(tab: AnyHashable)
}

/// 모든 이벤트 메서드에 빈 기본 구현을 제공합니다.
public extension NavigationEventObserverProtocol {
    func didPush(route: AnyHashable) {}
    func didPop() {}
    func didPopToRoot() {}
    func didReplace(with routes: [AnyHashable]) {}
    func didPopTo(route: AnyHashable) {}
    func didPresent(route: AnyHashable, style: PresentationStyle) {}
    func didDismiss() {}
    func didSelectTab(tab: AnyHashable) {}
}
