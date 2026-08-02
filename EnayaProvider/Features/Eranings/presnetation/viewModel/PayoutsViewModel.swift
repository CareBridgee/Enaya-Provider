//
//  PayoutsViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//

import Foundation


@MainActor
final class PayoutsViewModel: ObservableObject {
    @Published private(set) var summary: PayoutSummary?
    @Published private(set) var history: [PayoutTransaction] = []
    
    private let coordinator: EarningsCoordinator
    private let useCase: FetchEarningsDataUseCase

    init(coordinator: EarningsCoordinator, useCase: FetchEarningsDataUseCase) {
        self.coordinator = coordinator
        self.useCase = useCase
    }

    func loadData() {
        Task {
            summary = try? await useCase.fetchPayoutSummary()
            history = (try? await useCase.fetchPayoutHistory()) ?? []
        }
    }

    func goBackTapped() {
        coordinator.goBack()
    }
}
