//
//  MainTabCoordinator.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//

import Foundation

@MainActor
final class MainTabCoordinator: ObservableObject {

    @Published var selectedTab: AppTab = .hub
    @Published var currentNotification: NotificationData?

    let homeCoordinator: HomeCoordinator
//    let trackerCoordinator: TrackerCoordinator
//    let availabilityCoordinator: AvailabilityCoordinator
    let earningsCoordinator: EarningsCoordinator
    
    private var notificationsHubService: NotificationsHubServiceProtocol

    init(appState: AppState, container: DIContainer) {
        self.homeCoordinator = HomeCoordinator()
        self.earningsCoordinator = EarningsCoordinator()
        
        self.notificationsHubService = container.getNotificationsHubService()
        
        wireCrossTabNavigation()
        setupNotifications()
    }

    // MARK: - Cross-Tab Wiring

    private func wireCrossTabNavigation() {
        // Wire Home's cross-tab actions here once Tracker/Availability/Earnings exist, e.g.:
        // homeCoordinator.onOpenTracker = { [weak self] in self?.select(.tracker) }
    }

    func select(_ tab: AppTab) {
        selectedTab = tab
    }
    
    // MARK: - Notifications Setup
    
    private func setupNotifications() {
        notificationsHubService.onNotificationReceived = { [weak self] response in
            guard let self = self else { return }
            
            let data = NotificationData(
                title: response.title,
                message: response.message,
                type: response.type
            )
            self.currentNotification = data
        }
        notificationsHubService.connectAndSubscribe()
    }

    func handleNotificationTap() {
        guard let notif = currentNotification else { return }
        if notif.type == "MESSAGE" {
            // self.select(.tracker)
        }
    }
}
