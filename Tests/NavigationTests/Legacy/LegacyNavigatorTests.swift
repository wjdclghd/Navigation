//
//  LegacyNavigatorTests.swift
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
final class LegacyNavigatorTests {
    @Test
    func legacyNavigator_invokesHandlers() {
        var pushCount = 0
        var popCount = 0
        var popToRootCount = 0
        var presentCount = 0
        var dismissCount = 0

        let navigator = LegacyNavigator<TestRoute>(
            push: { _ in pushCount += 1 },
            pop: { popCount += 1 },
            popToRoot: { popToRootCount += 1 },
            present: { _ in presentCount += 1 },
            dismiss: { dismissCount += 1 }
        )

        navigator.push(.a)
        navigator.present(.b)
        navigator.pop()
        navigator.popToRoot()
        navigator.dismiss()

        #expect(pushCount == 1)
        #expect(presentCount == 1)
        #expect(popCount == 1)
        #expect(popToRootCount == 1)
        #expect(dismissCount == 1)
    }
}
