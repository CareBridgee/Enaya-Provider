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
    @StateObject private var coordinator = MainTabCoordinator()

    var body: some View {
        tabContent
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ProviderTabBar(selectedTab: Binding(
                    get: { coordinator.selectedTab },
                    set: { coordinator.select($0) }
                ))
            }
    }

    private var tabContent: some View {
        ZStack {
            HomeCoordinatorView(container: container, coordinator: coordinator.homeCoordinator)
                .opacity(coordinator.selectedTab == .hub ? 1 : 0)
                .allowsHitTesting(coordinator.selectedTab == .hub)

            // Tracker, Availability, and Earnings tabs land here the same way once built.
        }
        .animation(.easeInOut(duration: 0.15), value: coordinator.selectedTab)
    }
}