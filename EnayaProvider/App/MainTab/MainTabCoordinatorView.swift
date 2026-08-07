//
//  MainTabCoordinatorView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//

import SwiftUI

struct MainTabCoordinatorView: View {

    let container: DIContainer
    let appState: AppState
    @StateObject private var coordinator: MainTabCoordinator

    init(container: DIContainer, appState: AppState) {
        self.container = container
        self.appState = appState
        _coordinator = StateObject(wrappedValue: MainTabCoordinator(appState: appState, container: container))
    }

    var body: some View {
        tabContent
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ProviderTabBar(selectedTab: Binding(
                    get: { coordinator.selectedTab },
                    set: { coordinator.select($0) }
                ))
            }
            .notificationBanner(data: $coordinator.currentNotification) {
                coordinator.handleNotificationTap()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var tabContent: some View {
        ZStack {
            HomeCoordinatorView(container: container, coordinator: coordinator.homeCoordinator)
                .opacity(coordinator.selectedTab == .hub ? 1 : 0)
                .allowsHitTesting(coordinator.selectedTab == .hub)
            
            EarningsCoordinatorView(container: container, coordinator: coordinator.earningsCoordinator)
                .opacity(coordinator.selectedTab == .earnings ? 1 : 0)
                .allowsHitTesting(coordinator.selectedTab == .earnings)
            
        }
        .animation(.easeInOut(duration: 0.15), value: coordinator.selectedTab)
    }
}
