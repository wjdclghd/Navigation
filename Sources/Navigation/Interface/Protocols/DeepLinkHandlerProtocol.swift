//
//  DeepLinkHandlerProtocol.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Foundation

/*
 딥링크 URL을 Route로 변환하는 처리기 프로토콜입니다.

 URL 스킴 또는 유니버설 링크를 파싱하여 앱 내 이동 경로를 결정하는
 역할을 App 타겟 또는 Feature 모듈에 위임합니다.
 Navigation 모듈은 변환 결과를 받아 Navigator.replace(with:) 등으로
 연결하는 책임은 담당하지 않습니다.

 담당 역할
 - 주어진 URL을 처리할 수 있는지 여부 판단
 - URL을 Route 값으로 변환

 담당하지 않는 역할
 - URL 수신 및 감지 (AppDelegate, SceneDelegate에서 처리)
 - 변환된 Route를 Navigator에 전달하는 연결 로직

 설계 원칙
 - Sendable: 비동기 환경에서 안전하게 전달될 수 있도록 Sendable을 요구합니다.
 - associatedtype Route를 통해 각 도메인의 Route 타입에 맞게 구현합니다.
 */
public protocol DeepLinkHandlerProtocol: Sendable {
    associatedtype Route: Hashable

    /*
     주어진 URL을 이 핸들러가 처리할 수 있는지 확인합니다.

     여러 핸들러가 등록된 경우 순서대로 호출하여,
     true를 반환하는 핸들러에게만 route(from:)을 위임합니다.

     Parameters:
     - url: 처리 여부를 확인할 URL

     Returns:
     - 처리 가능하면 true, 그렇지 않으면 false
     */
    func canHandle(_ url: URL) -> Bool

    /*
     URL을 Route로 변환합니다.

     canHandle(_:)이 true인 URL에 대해 호출하는 것을 권장합니다.
     변환할 수 없는 경로라면 nil을 반환합니다.

     Parameters:
     - url: Route로 변환할 URL

     Returns:
     - 변환된 Route 값. 변환할 수 없으면 nil
     */
    func route(from url: URL) -> Route?
}
