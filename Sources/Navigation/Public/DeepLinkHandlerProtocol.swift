//
//  DeepLinkHandlerProtocol.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Foundation

public protocol DeepLinkHandlerProtocol: Sendable {
    associatedtype Route: Hashable
    func canHandle(_ url: URL) -> Bool
    func route(from url: URL) -> Route?
}
