//
//  TabNavigator.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

/*
 TabNavigatorProtocol의 타입 소거 래퍼입니다.

 Feature 모듈의 ViewModel은 TabNavigator<Tab>만 주입받으며,
 구체 구현체를 직접 알지 않습니다.
 App 타겟의 Coordinator가 구현체를 생성하고 TabNavigator로 감싸 주입합니다.

 담당 역할
 - TabNavigatorProtocol 구현체를 클로저로 캡처하여 타입 정보 은닉
 - 탭 선택 명령 전달 및 현재 선택된 탭 상태 노출

 메모리 안전성
 - 구현체는 [weak navigator]로 약하게 캡처합니다.
 - 구현체 해제 후 select(_:)는 아무 동작도 하지 않습니다.
 - 구현체 해제 후 selectedTab에 접근하면 _lastKnownTab을 반환합니다.
   select(_:) 호출마다 _lastKnownTab을 갱신하므로 마지막으로 선택한 탭이 유지됩니다.

 Swift 6 동시성
 - @MainActor: 모든 탭 전환과 상태 접근은 메인 스레드에서 실행됩니다.
 - @unchecked Sendable: @MainActor 격리를 직접 보장하므로 컴파일러 검사를 우회합니다.
 */
@MainActor
public final class TabNavigator<Tab: Hashable>: TabNavigatorProtocol, @unchecked Sendable {

    private let _select: (Tab) -> Void
    private let _selectedTab: () -> Tab?

    /*
     구현체가 해제된 이후에도 selectedTab이 마지막으로 알려진 값을 반환하도록
     유지하는 폴백 저장소입니다.

     select(_:) 호출 시마다 갱신되어, 구현체 해제 후 접근 시 안전한 값을 제공합니다.
     */
    private var _lastKnownTab: Tab

    /*
     현재 선택된 탭입니다.

     구현체가 유효한 동안에는 구현체의 selectedTab을 반환합니다.
     구현체가 해제된 이후에는 마지막으로 알려진 탭(_lastKnownTab)을 반환합니다.
     */
    public var selectedTab: Tab { _selectedTab() ?? _lastKnownTab }

    /*
     TabNavigatorProtocol을 채택한 구현체를 받아 TabNavigator를 생성합니다.

     구현체는 약하게 캡처되므로, 구현체의 생명주기는 호출부가 관리해야 합니다.
     초기 _lastKnownTab은 구현체의 현재 selectedTab으로 설정됩니다.

     Parameters:
     - navigator: 탭 전환을 처리할 TabNavigatorProtocol 구현체
     */
    public init<N: TabNavigatorProtocol>(_ navigator: N) where N.Tab == Tab {
        self._lastKnownTab = navigator.selectedTab
        self._select = { [weak navigator] tab in
            navigator?.select(tab)
        }
        self._selectedTab = { [weak navigator] in
            navigator?.selectedTab
        }
    }

    /*
     탭을 선택합니다.

     _lastKnownTab을 갱신한 뒤 구현체의 select(_:)를 호출합니다.
     구현체가 해제된 이후에는 _lastKnownTab만 갱신하고 아무 동작도 하지 않습니다.

     Parameters:
     - tab: 선택할 탭
     */
    public func select(_ tab: Tab) {
        _lastKnownTab = tab
        _select(tab)
    }
}
