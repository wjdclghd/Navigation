//
//  NavigatorProtocol.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

/*
 스택 기반 화면 이동을 추상화하는 프로토콜입니다.

 Feature 모듈의 ViewModel은 이 프로토콜을 통해 화면 이동을 요청하며,
 구체 구현체(StackNavigator, LegacyNavigator 등)를 직접 알지 않습니다.
 Navigator<Route> 타입 소거 래퍼를 통해 주입받는 것이 일반적입니다.

 담당 역할
 - push, pop, popToRoot, replace, pop(to:) 등 스택 조작 계약 정의
 - present, dismiss 모달 표시 계약 정의

 설계 원칙
 - @MainActor: 모든 화면 이동은 메인 스레드에서 실행됩니다.
 - AnyObject: 타입 소거 시 약한 참조 캡처를 지원합니다.
 - Sendable: Swift 6 동시성 경계를 넘어 안전하게 전달될 수 있습니다.
 */
@MainActor
public protocol NavigatorProtocol: AnyObject, Sendable {
    associatedtype Route: Hashable

    /* 새 화면을 스택에 추가합니다. */
    func push(_ route: Route)

    /* 스택의 최상단 화면을 제거합니다. 스택이 비어 있으면 아무 동작도 하지 않습니다. */
    func pop()

    /* 스택을 루트 화면만 남도록 초기화합니다. */
    func popToRoot()

    /*
     스택 전체를 주어진 Route 배열로 교체합니다.

     Parameters:
     - routes: 새로 구성할 스택 순서의 Route 배열
     */
    func replace(with routes: [Route])

    /*
     특정 Route까지 스택을 되돌립니다.

     스택에서 해당 Route의 마지막 위치를 기준으로 그 이후 항목을 모두 제거합니다.
     Route가 스택에 없으면 아무 동작도 하지 않습니다.

     Parameters:
     - route: 되돌아갈 대상 Route
     */
    func pop(to route: Route)

    /*
     모달 화면을 표시합니다.

     Parameters:
     - route: 표시할 화면에 해당하는 Route 값
     - style: 화면 표시 방식
     */
    func present(_ route: Route, style: PresentationStyle)

    /* 현재 표시 중인 모달 화면을 닫습니다. */
    func dismiss()
}
