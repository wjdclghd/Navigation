//
//  NavigationEventObserverProtocol.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Foundation

/*
 화면 이동 이벤트를 수신하는 옵저버 프로토콜입니다.

 Analytics 연결, 로깅, 화면 이동 추적 등의 용도로 사용합니다.
 Navigator<Route>에 addObserver(_:)로 등록하면,
 push, pop, present 등 모든 이동 시점에 자동으로 알림을 받습니다.

 담당 역할
 - 화면 이동 이벤트 수신 계약 정의
 - default extension을 통해 필요한 이벤트만 선택적으로 구현 가능

 설계 원칙
 - @MainActor: 모든 이벤트는 메인 스레드에서 전달됩니다.
 - AnyObject: Navigator가 옵저버를 strong 참조로 관리하며,
   순환 참조가 우려될 경우 호출부에서 생명주기를 직접 관리해야 합니다.
 - Route 타입은 AnyHashable로 전달되므로, 수신부에서 원하는 Route 타입으로 캐스팅합니다.
 */
@MainActor
public protocol NavigationEventObserverProtocol: AnyObject, Sendable {

    /* push 이벤트가 발생했을 때 호출됩니다. */
    func didPush(route: AnyHashable)

    /* pop 이벤트가 발생했을 때 호출됩니다. */
    func didPop()

    /* popToRoot 이벤트가 발생했을 때 호출됩니다. */
    func didPopToRoot()

    /*
     replace 이벤트가 발생했을 때 호출됩니다.

     Parameters:
     - routes: 새로 구성된 스택의 Route 배열
     */
    func didReplace(with routes: [AnyHashable])

    /*
     pop(to:) 이벤트가 발생했을 때 호출됩니다.

     Parameters:
     - route: 되돌아간 대상 Route
     */
    func didPopTo(route: AnyHashable)

    /*
     present 이벤트가 발생했을 때 호출됩니다.

     Parameters:
     - route: 표시된 화면의 Route
     - style: 사용된 표시 방식
     */
    func didPresent(route: AnyHashable, style: PresentationStyle)

    /* dismiss 이벤트가 발생했을 때 호출됩니다. */
    func didDismiss()

    /*
     탭 전환 이벤트가 발생했을 때 호출됩니다.

     Parameters:
     - tab: 전환된 대상 탭
     */
    func didSelectTab(tab: AnyHashable)
}

/*
 모든 이벤트 메서드에 빈 기본 구현을 제공합니다.

 채택부는 관심 있는 이벤트만 선택적으로 구현할 수 있으며,
 구현하지 않은 메서드는 자동으로 빈 동작으로 처리됩니다.
 */
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
