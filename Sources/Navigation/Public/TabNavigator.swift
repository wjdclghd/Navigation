//
//  TabNavigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

@MainActor
public final class TabNavigator<Tab: Hashable>: TabNavigatorProtocol, @unchecked Sendable {

    private let _select: (Tab) -> Void
    private let _selectedTab: () -> Tab

    public var selectedTab: Tab { _selectedTab() }

    public init<N: TabNavigatorProtocol>(_ navigator: N) where N.Tab == Tab {
        self._select = { [weak navigator] tab in
            navigator?.select(tab)
        }
        self._selectedTab = { [weak navigator] in
            guard let navigator else {
                preconditionFailure("TabNavigator: 래핑된 navigator 가 해제된 후 selectedTab 에 접근했습니다.")
            }
            return navigator.selectedTab
        }
    }

    public func select(_ tab: Tab) {
        _select(tab)
    }
}
