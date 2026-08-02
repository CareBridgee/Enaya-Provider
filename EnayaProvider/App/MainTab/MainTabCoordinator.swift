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

    let homeCoordinator: HomeCoordinator
//    let trackerCoordinator: TrackerCoordinator
//    let availabilityCoordinator: AvailabilityCoordinator
    let earningsCoordinator: EarningsCoordinator

    init() {
        self.homeCoordinator = HomeCoordinator()
        self.earningsCoordinator = EarningsCoordinator()
        wireCrossTabNavigation()
    }

    // MARK: - Cross-Tab Wiring

    private func wireCrossTabNavigation() {
        // Wire Home's cross-tab actions here once Tracker/Availability/Earnings exist, e.g.:
        // homeCoordinator.onOpenTracker = { [weak self] in self?.select(.tracker) }
    }

    func select(_ tab: AppTab) {
        selectedTab = tab
    }
}
