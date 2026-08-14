//
//  MainTabCoordinator.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//

import Foundation

@MainActor
final class MainTabCoordinator: ObservableObject {

    @Published var selectedTab: AppTab = .home
    @Published var currentNotification: NotificationData?

    let homeCoordinator: HomeCoordinator
    let earningsCoordinator: EarningsCoordinator
    let profileCoordinator: ProfileCoordinator
    
    private var notificationsHubService: NotificationsHubServiceProtocol

    init(appState: AppState, container: DIContainer) {
        self.homeCoordinator = HomeCoordinator()
        self.earningsCoordinator = EarningsCoordinator()
        self.profileCoordinator = container.makeProfileCoordinator()
        
        self.notificationsHubService = container.getNotificationsHubService()
        
        wireCrossTabNavigation()
        setupNotifications()
    }

    private func wireCrossTabNavigation() {}

    func select(_ tab: AppTab) {
        selectedTab = tab
    }
    
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
            // self.select(.activeJobs)
        }
    }
}
