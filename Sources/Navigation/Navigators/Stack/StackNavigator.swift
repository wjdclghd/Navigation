//
//  StackNavigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import SwiftUI

/*
 iOS 16 이상에서 NavigationStack 기반 화면 이동을 처리하는 구현체입니다.

 @Published 프로퍼티를 통해 SwiftUI View에 화면 상태를 제공하며,
 ObservableObject로 View가 상태 변화를 자동으로 감지합니다.
 App 타겟의 Coordinator가 이 인스턴스를 생성하고, Navigator<Route>로 감싸
 ViewModel에 주입합니다.

 담당 역할
 - path 배열을 통한 스택 상태 관리
 - presentationItem을 통한 모달 표시 상태 관리
 - NavigationDetent를 SwiftUI PresentationDetent로 변환

 담당하지 않는 역할
 - 화면 이동 이벤트 옵저버 알림 (Navigator 타입 소거 계층에서 처리)
 - Route와 View의 매핑 (App 타겟 또는 Feature 모듈에서 처리)

 Swift 6 동시성
 - @MainActor: 모든 상태 변경은 메인 스레드에서 실행됩니다.
 - @unchecked Sendable: @MainActor 격리를 직접 보장하므로 컴파일러 검사를 우회합니다.
 */
@available(iOS 16.0, *)
@MainActor
public final class StackNavigator<Route: Hashable>: ObservableObject, NavigatorProtocol, @unchecked Sendable {

    /*
     현재 스택의 화면 순서입니다.

     NavigationStack(path:) 바인딩에 연결하여 View가 스택 상태를 반영합니다.
     외부에서 직접 변경할 수 없으며, NavigatorProtocol 메서드를 통해서만 조작합니다.
     */
    @Published public private(set) var path: [Route] = []

    /*
     현재 표시 중인 모달 정보입니다.

     .sheet(item:) 또는 .fullScreenCover(item:) 바인딩에 연결합니다.
     nil이면 모달이 닫힌 상태이고, 값이 있으면 해당 Route를 모달로 표시합니다.
     */
    @Published public private(set) var presentationItem: PresentationItem<Route>? = nil

    public init() {}

    public func push(_ route: Route) {
        path.append(route)
    }

    /*
     스택의 최상단 화면을 제거합니다.

     스택이 이미 비어 있으면 아무 동작도 하지 않습니다.
     */
    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path.removeAll()
    }

    public func replace(with routes: [Route]) {
        path = routes
    }

    /*
     특정 Route까지 스택을 되돌립니다.

     스택에서 해당 Route의 마지막 위치를 기준으로 그 이후 항목을 모두 제거합니다.
     Route가 스택에 없으면 아무 동작도 하지 않습니다.

     Parameters:
     - route: 되돌아갈 대상 Route
     */
    public func pop(to route: Route) {
        guard let index = path.lastIndex(of: route) else { return }
        path = Array(path.prefix(through: index))
    }

    public func present(_ route: Route, style: PresentationStyle = .sheet) {
        presentationItem = PresentationItem(route: route, style: style)
    }

    public func dismiss() {
        presentationItem = nil
    }
}

/*
 Navigation 모듈의 NavigationDetent를 SwiftUI의 PresentationDetent로 변환합니다.

 SwiftUI 의존성을 StackNavigator 내부로 제한하기 위해 extension으로 분리합니다.
 외부 계층은 NavigationDetent만 사용하고, SwiftUI 타입은 View 연결 시점에만 필요합니다.
 */
@available(iOS 16.0, *)
extension NavigationDetent {
    var swiftUIDetent: PresentationDetent {
        switch self {
        case .medium:              return .medium
        case .large:               return .large
        case .fraction(let value): return .fraction(value)
        case .height(let value):   return .height(value)
        }
    }
}
