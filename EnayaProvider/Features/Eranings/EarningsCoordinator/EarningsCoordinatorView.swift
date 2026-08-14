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
    /// Whether the Wallet/Earnings tab is the one currently selected.
    ///
    /// The main tab bar keeps every tab's view alive at all times (it toggles
    /// opacity instead of inserting/removing views), so SwiftUI's `.onAppear`
    /// only fires once, the first time this view is built - not every time the
    /// user switches to this tab. We use `isActive` to detect real
    /// tab-selection changes and refresh the earnings list then, instead of
    /// relying solely on `.onAppear`.
    let isActive: Bool

    @StateObject private var earningsHistoryViewModel: EarningsHistoryViewModel

    init(container: DIContainer, coordinator: EarningsCoordinator, isActive: Bool = true) {
        self.container = container
        self.coordinator = coordinator
        self.isActive = isActive
        _earningsHistoryViewModel = StateObject(
            wrappedValue: container.makeEarningsHistoryViewModel(coordinator: coordinator)
        )
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            EarningsHistoryView(viewModel: earningsHistoryViewModel)
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
        .onChange(of: isActive) { active in
            if active {
                earningsHistoryViewModel.loadData()
            }
        }
    }
}
