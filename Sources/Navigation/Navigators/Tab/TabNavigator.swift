//
//  TabNavigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

/// `TabNavigatorProtocol`의 타입 소거 래퍼입니다.
///
/// Feature 모듈은 구체 구현체 대신 이 타입을 주입받아 탭 전환을 요청합니다.
@MainActor
public final class TabNavigator<Tab: Hashable>: TabNavigatorProtocol, @unchecked Sendable {

    private let _select: (Tab) -> Void
    private let _selectedTab: () -> Tab?
    private var observers: [any NavigationEventObserverProtocol] = []

    private var _lastKnownTab: Tab

    /// 현재 선택된 탭입니다.
    ///
    /// 구현체가 해제된 이후에는 마지막으로 알려진 탭을 반환합니다.
    public var selectedTab: Tab { _selectedTab() ?? _lastKnownTab }

    /// `TabNavigatorProtocol`을 채택한 구현체를 받아 TabNavigator를 생성합니다.
    ///
    /// 구현체는 약하게 캡처되므로 구현체의 생명주기는 호출부가 관리합니다.
    ///
    /// - Parameter navigator: 탭 전환을 처리할 구현체입니다.
    public init<N: TabNavigatorProtocol>(_ navigator: N) where N.Tab == Tab {
        self._lastKnownTab = navigator.selectedTab
        self._select = { [weak navigator] tab in
            navigator?.select(tab)
        }
        self._selectedTab = { [weak navigator] in
            navigator?.selectedTab
        }
    }

    // MARK: - Observer

    /// 옵저버를 등록합니다.
    ///
    /// 동일 인스턴스를 중복으로 등록하면 첫 번째 등록만 유지됩니다.
    ///
    /// - Parameter observer: 이벤트를 수신할 옵저버입니다.
    public func addObserver(_ observer: any NavigationEventObserverProtocol) {
        guard !observers.contains(where: { ($0 as AnyObject) === (observer as AnyObject) }) else { return }
        observers.append(observer)
    }

    /// 등록된 옵저버를 제거합니다.
    ///
    /// - Parameter observer: 제거할 옵저버입니다.
    public func removeObserver(_ observer: any NavigationEventObserverProtocol) {
        observers.removeAll { ($0 as AnyObject) === (observer as AnyObject) }
    }

    /// 탭을 선택합니다.
    ///
    /// 구현체가 해제된 이후에는 마지막으로 알려진 탭만 갱신합니다.
    ///
    /// - Parameter tab: 선택할 탭입니다.
    public func select(_ tab: Tab) {
        _lastKnownTab = tab
        _select(tab)
        observers.forEach { $0.didSelectTab(tab: AnyHashable(tab)) }
    }
}
