//
//  StackNavigatorTests.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import Foundation
import Testing
@testable import Navigation

private enum TestRoute: Hashable {
    case a
    case b
}

@MainActor
final class StackNavigatorTests {
    @Test
    @available(iOS 16.0, *)
    func stackNavigator_updatesPathAndPresented() {
        let navigator = StackNavigator<TestRoute>()

        navigator.push(.a)
        #expect(navigator.path == [.a])

        navigator.push(.b)
        #expect(navigator.path == [.a, .b])

        navigator.pop()
        #expect(navigator.path == [.a])

        navigator.popToRoot()
        #expect(navigator.path.isEmpty)

        navigator.present(.b)
        #expect(navigator.presented == .b)

        navigator.dismiss()
        #expect(navigator.presented == nil)
    }
}
