//
//  NavigatorProtocol.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

/// 스택 기반 화면 이동을 추상화하는 프로토콜입니다.
///
/// Feature 모듈은 이 계약을 통해 화면 이동을 요청하고 구체 구현체를 직접 알지 않습니다.
@MainActor
public protocol NavigatorProtocol: AnyObject, Sendable {
    associatedtype Route: Hashable

    /// 새 화면을 스택에 추가합니다.
    func push(_ route: Route)

    /// 스택의 최상단 화면을 제거합니다.
    func pop()

    /// 스택을 루트 화면만 남도록 초기화합니다.
    func popToRoot()

    /// 스택 전체를 주어진 Route 배열로 교체합니다.
    ///
    /// - Parameter routes: 새로 구성할 스택 순서의 Route 배열입니다.
    func replace(with routes: [Route])

    /// 특정 Route까지 스택을 되돌립니다.
    ///
    /// 스택에서 해당 Route의 마지막 위치를 기준으로 그 이후 항목을 모두 제거합니다.
    ///
    /// - Parameter route: 되돌아갈 대상 Route입니다.
    func pop(to route: Route)

    /// 모달 화면을 표시합니다.
    ///
    /// - Parameters:
    ///   - route: 표시할 화면에 해당하는 Route 값입니다.
    ///   - style: 화면 표시 방식입니다.
    func present(_ route: Route, style: PresentationStyle)

    /// 현재 표시 중인 모달 화면을 닫습니다.
    func dismiss()
}
