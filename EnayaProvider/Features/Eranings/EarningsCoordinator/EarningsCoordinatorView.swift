//
//  EarningsCoordinatorView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI

struct EarningsCoordinatorView: View {
    let container: DIContainer
    @ObservedObject var coordinator: EarningsCoordinator

    init(container: DIContainer, coordinator: EarningsCoordinator) {
        self.container = container
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            EarningsHistoryView(
                viewModel: container.makeEarningsHistoryViewModel(coordinator: coordinator)
            )
            .navigationDestination(for: EarningsRoute.self) { route in
                switch route {
                case .payouts:
                    PayoutsView(
                        viewModel: container.makePayoutsViewModel(coordinator: coordinator)
                    )
                case .history:
                    HistoryView(
                        viewModel: container.makeHistoryViewModel(coordinator: coordinator)
                    )
                }
            }
        }
    }
}
