//
//  EarningsHistoryViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//

import Foundation

@MainActor
final class EarningsHistoryViewModel: ObservableObject {
    @Published private(set) var summary: EarningsSummary?
    @Published private(set) var jobs: [JobEarning] = []
    
    private let coordinator: EarningsCoordinator
    private let useCase: FetchEarningsDataUseCase

    init(coordinator: EarningsCoordinator, useCase: FetchEarningsDataUseCase) {
        self.coordinator = coordinator
        self.useCase = useCase
    }

    func loadData() {
        Task {
            summary = try? await useCase.fetchSummary()
        
            jobs = (try? await useCase.fetchJobs()) ?? []
        }
    }

    func viewPayoutsTapped() {
        coordinator.goToPayouts()
    }
}
