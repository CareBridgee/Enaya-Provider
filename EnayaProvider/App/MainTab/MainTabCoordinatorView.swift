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
    @StateObject private var homeViewModel: HomeViewModel

    init(container: DIContainer, appState: AppState) {
        self.container = container
        self.appState = appState
        _coordinator = StateObject(wrappedValue: MainTabCoordinator(appState: appState, container: container))
        _homeViewModel = StateObject(wrappedValue: container.makeHomeViewModel())
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.backGround
                .ignoresSafeArea()

            tabContent
                .padding(.bottom, coordinator.isTabBarVisible ? 50 : Spacing.s0)

            if coordinator.isTabBarVisible {
                ProviderTabBar(selectedTab: Binding(
                    get: { coordinator.selectedTab },
                    set: { coordinator.select($0) }
                ))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: coordinator.isTabBarVisible)
        .background(Color.backGround.ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .notificationBanner(data: $coordinator.currentNotification) {
            coordinator.handleNotificationTap()
        }
        .sheet(item: $homeViewModel.editingJobRequest) { request in
            EditOfferPopupView(
                jobRequest: request,
                proposedPriceValue: $homeViewModel.proposedPriceValue,
                onCancel: { homeViewModel.cancelEditing() },
                onSave: { homeViewModel.saveEditedOffer() }
            )
            .presentationDetents([.fraction(0.55), .medium])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: Binding(
            get: { homeViewModel.isWaitingForPatient },
            set: { if !$0 { homeViewModel.cancelWaitingOffer() } }
        )) {
            ZStack {
                Color.black.opacity(0.6).ignoresSafeArea()
                PatientResponseWaitingView(onCancel: { homeViewModel.cancelWaitingOffer() })
            }
            .presentationBackground(.clear)
        }
        .alert("Notice", isPresented: $homeViewModel.showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(homeViewModel.alertMessage)
        }
    }

    private var tabContent: some View {
        ZStack {
            HomeCoordinatorView(
                container: container,
                coordinator: coordinator.homeCoordinator,
                viewModel: homeViewModel,
                onViewAll: { coordinator.select(.activeJobs) }
            )
            .opacity(coordinator.selectedTab == .home ? 1 : 0)
            .allowsHitTesting(coordinator.selectedTab == .home)
            
            ActiveJobsView(viewModel: homeViewModel)
                .opacity(coordinator.selectedTab == .activeJobs ? 1 : 0)
                .allowsHitTesting(coordinator.selectedTab == .activeJobs)
            
            EarningsCoordinatorView(
                container: container,
                coordinator: coordinator.earningsCoordinator,
                isActive: coordinator.selectedTab == .wallet
            )
            .opacity(coordinator.selectedTab == .wallet ? 1 : 0)
            .allowsHitTesting(coordinator.selectedTab == .wallet)
            
            ProfileCoordinatorView(
                container: container,
                appState: appState,
                coordinator: coordinator.profileCoordinator
            )
            .opacity(coordinator.selectedTab == .profile ? 1 : 0)
            .allowsHitTesting(coordinator.selectedTab == .profile)
        }
        .animation(.easeInOut(duration: 0.15), value: coordinator.selectedTab)
    }
}
