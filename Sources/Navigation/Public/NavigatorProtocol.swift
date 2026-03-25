//
//  NavigatorProtocol.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Foundation

@MainActor
public protocol NavigatorProtocol: AnyObject {
    /// Navigation 대상이 되는 Route 타입입니다.
    /// Hashable 제약은 스택/경로 기반 상태 관리에 사용됩니다.
    associatedtype Route: Hashable

    /// 현재 스택에 Route를 추가합니다.
    func push(_ route: Route)
    /// 현재 스택의 마지막 Route를 제거합니다.
    func pop()
    /// 스택을 초기 상태로 되돌립니다.
    func popToRoot()

    /// 모달 형태로 Route를 표시합니다.
    func present(_ route: Route)
    /// 현재 표시된 모달을 해제합니다.
    func dismiss()
}
