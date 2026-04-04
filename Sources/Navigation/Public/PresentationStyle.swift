//
//  PresentationStyle.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Foundation

public enum NavigationDetent: Hashable, Sendable {
    case medium
    case large
    case fraction(CGFloat)
    case height(CGFloat)
}

public enum PresentationStyle: Hashable, Sendable {
    case sheet
    case fullScreenCover
    case sheetWithDetents(Set<NavigationDetent>)
}

public struct PresentationItem<Route: Hashable>: Identifiable, Hashable {

    public let id: UUID
    public let route: Route
    public let style: PresentationStyle

    public init(route: Route, style: PresentationStyle = .sheet) {
        self.id = UUID()
        self.route = route
        self.style = style
    }
}
