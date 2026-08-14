//
//  OfferHistoryViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 14/08/2026.
//
//  (file name kept for project-reference stability)
//

import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var items: [NurseServiceRequestHistoryItem] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let coordinator: EarningsCoordinator
    private let useCase: FetchNurseHistoryUseCase

    init(coordinator: EarningsCoordinator, useCase: FetchNurseHistoryUseCase) {
        self.coordinator = coordinator
        self.useCase = useCase
    }

    func loadData() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                items = try await useCase.execute()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func retryTapped() {
        loadData()
    }

    func goBackTapped() {
        coordinator.goBack()
    }
}
