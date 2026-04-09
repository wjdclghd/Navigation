//
//  TabNavigatorProtocol.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

/*
 탭바 기반 화면 전환을 추상화하는 프로토콜입니다.

 Feature 모듈의 ViewModel은 이 프로토콜을 통해 탭을 전환하며,
 구체 구현체를 직접 알지 않습니다.
 TabNavigator<Tab> 타입 소거 래퍼를 통해 주입받는 것이 일반적입니다.

 설계 원칙
 - @MainActor: 탭 전환은 메인 스레드에서 실행됩니다.
 - AnyObject: 타입 소거 시 약한 참조 캡처를 지원합니다.
 - Sendable: Swift 6 동시성 경계를 넘어 안전하게 전달될 수 있습니다.
 */
@MainActor
public protocol TabNavigatorProtocol: AnyObject, Sendable {
    associatedtype Tab: Hashable

    /* 현재 선택된 탭입니다. */
    var selectedTab: Tab { get }

    /*
     지정한 탭으로 전환합니다.

     Parameters:
     - tab: 전환할 대상 탭
     */
    func select(_ tab: Tab)
}
