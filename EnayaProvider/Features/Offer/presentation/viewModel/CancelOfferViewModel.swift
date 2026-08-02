//
//  CancelOfferViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation

@MainActor
final class CancelOfferViewModel: ObservableObject {

    @Published var selectedReason: CancellationReason = .vehicleIssue
    @Published var detailText: String = ""
    @Published private(set) var isSubmitting = false

    private let coordinator: OfferCoordinator
    private let cancelOfferUseCase: CancelOfferUseCaseProtocol
    private let onCancelled: () -> Void

    init(coordinator: OfferCoordinator, cancelOfferUseCase: CancelOfferUseCaseProtocol, onCancelled: @escaping () -> Void) {
        self.coordinator = coordinator
        self.cancelOfferUseCase = cancelOfferUseCase
        self.onCancelled = onCancelled
    }

    var offer: ConfirmedOffer { coordinator.offer }

    var isConfirmEnabled: Bool {
        selectedReason != .other || !detailText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func dismissTapped() {
        coordinator.dismissCancelSheet()
    }

    func confirmTapped() {
        guard isConfirmEnabled, !isSubmitting else { return }
        isSubmitting = true

        Task {
            try? await cancelOfferUseCase.execute(
                offerId: offer.id,
                reason: selectedReason,
                detail: selectedReason == .other ? detailText : nil
            )
            coordinator.markCancelled()
            isSubmitting = false
            coordinator.dismissCancelSheet()
            onCancelled()
        }
    }
}