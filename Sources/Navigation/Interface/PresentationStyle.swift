//
//  PresentationStyle.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Foundation

/// 시트의 높이 정책을 나타내는 타입입니다.
///
/// SwiftUI의 `PresentationDetent`를 공개 인터페이스에 직접 노출하지 않기 위해 사용합니다.
public enum NavigationDetent: Hashable, Sendable {
    case medium
    case large
    case fraction(CGFloat)
    case height(CGFloat)
}

/// 화면을 표시하는 방식을 나타내는 타입입니다.
///
/// `present(_:style:)` 호출 시 전달하며 View 계층의 표시 방식을 결정합니다.
public enum PresentationStyle: Hashable, Sendable {
    case sheet
    case fullScreenCover
    case sheetWithDetents(Set<NavigationDetent>)
}

/// 모달 표시 상태를 SwiftUI의 `.sheet(item:)` 및 `.fullScreenCover(item:)`와 연결하는 컨테이너입니다.
///
/// `present(_:style:)`이 호출될 때마다 새로운 식별자를 생성합니다.
public struct PresentationItem<Route: Hashable>: Identifiable, Hashable {

    /// 표시 요청마다 고유하게 생성되는 식별자입니다.
    public let id: UUID

    /// 표시할 대상 Route입니다.
    public let route: Route

    /// 화면을 표시하는 방식입니다.
    public let style: PresentationStyle

    /// 표시할 Route와 방식을 지정하여 PresentationItem을 생성합니다.
    ///
    /// - Parameters:
    ///   - route: 표시할 화면에 해당하는 Route 값입니다.
    ///   - style: 화면 표시 방식입니다. 기본값은 `.sheet`입니다.
    public init(route: Route, style: PresentationStyle = .sheet) {
        self.id = UUID()
        self.route = route
        self.style = style
    }
}
