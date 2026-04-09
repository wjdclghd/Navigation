//
//  PresentationStyle.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Foundation

/*
 모달 표시 방식과 관련된 값 타입 모음입니다.

 Navigation 모듈은 SwiftUI의 PresentationDetent를 직접 노출하지 않고
 자체 타입으로 추상화하여, 상위 계층이 SwiftUI에 직접 의존하지 않도록 합니다.

 포함된 타입
 - NavigationDetent: 시트 높이 설정값
 - PresentationStyle: 화면 표시 방식
 - PresentationItem: 모달 표시 상태를 담는 식별 가능한 컨테이너
 */

/*
 시트의 높이 정책을 나타내는 타입입니다.

 SwiftUI의 PresentationDetent를 직접 노출하면 Navigation 모듈이
 SwiftUI에 의존하게 되고, iOS 16 미만에서 컴파일 타임 Sendable 검증이
 실패할 수 있습니다.
 StackNavigator 내부에서만 swiftUIDetent 변환을 수행하고,
 이 타입을 공개 인터페이스로 사용합니다.
 */
public enum NavigationDetent: Hashable, Sendable {
    case medium
    case large
    case fraction(CGFloat)
    case height(CGFloat)
}

/*
 화면을 표시하는 방식을 나타내는 타입입니다.

 present(_:style:)을 호출할 때 함께 전달하며,
 View 계층이 어떤 방식으로 화면을 덮을지를 결정합니다.

 sheetWithDetents는 iOS 16 이상에서만 동작합니다.
 StackNavigator의 View modifier 연결 시 반영됩니다.
 */
public enum PresentationStyle: Hashable, Sendable {
    case sheet
    case fullScreenCover
    case sheetWithDetents(Set<NavigationDetent>)
}

/*
 모달 표시 상태를 SwiftUI의 .sheet(item:) 및 .fullScreenCover(item:)와
 연결하기 위한 식별 가능한 컨테이너입니다.

 present(_:style:)이 호출될 때마다 새로운 UUID가 생성되므로,
 동일한 Route를 연속 표시하더라도 SwiftUI가 항상 새 모달로 인식합니다.

 담당 역할
 - 표시할 Route와 PresentationStyle을 함께 보관
 - Identifiable 및 Hashable 준수로 SwiftUI 바인딩 지원
 */
public struct PresentationItem<Route: Hashable>: Identifiable, Hashable {

    /*
     표시 요청마다 고유하게 생성되는 식별자입니다.

     같은 Route를 연속으로 present하더라도 SwiftUI가 각각 별개의
     모달 트리거로 처리할 수 있도록 매번 새로운 UUID를 부여합니다.
     */
    public let id: UUID

    /* 표시할 대상 Route입니다. */
    public let route: Route

    /* 화면을 표시하는 방식입니다. */
    public let style: PresentationStyle

    /*
     표시할 Route와 방식을 지정하여 PresentationItem을 생성합니다.

     Parameters:
     - route: 표시할 화면에 해당하는 Route 값
     - style: 화면 표시 방식. 기본값은 .sheet
     */
    public init(route: Route, style: PresentationStyle = .sheet) {
        self.id = UUID()
        self.route = route
        self.style = style
    }
}
