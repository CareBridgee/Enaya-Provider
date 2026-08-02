//
//  OfferConfirmedViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation

@MainActor
final class OfferConfirmedViewModel: ObservableObject {

    @Published private(set) var isProcessing = false

    private let coordinator: OfferCoordinator
    private let startVisitUseCase: StartVisitUseCaseProtocol
    private let completeVisitUseCase: CompleteVisitUseCaseProtocol

    init(
        coordinator: OfferCoordinator,
        startVisitUseCase: StartVisitUseCaseProtocol,
        completeVisitUseCase: CompleteVisitUseCaseProtocol
    ) {
        self.coordinator = coordinator
        self.startVisitUseCase = startVisitUseCase
        self.completeVisitUseCase = completeVisitUseCase
    }

    var canCancel: Bool { coordinator.offer.status == .confirmed }

    var titleText: String {
        coordinator.offer.status == .visitStarted ? "Visit Started" : "Offer Confirmed!"
    }

    var subtitleText: String {
        coordinator.offer.status == .visitStarted
            ? "You've arrived and the care session is now underway."
            : "Your patient is waiting for you"
    }

    var actionButtonTitle: String {
        coordinator.offer.status == .visitStarted ? "Complete Visit" : "Show Scan QR Code"
    }

    func openDetails() {
        coordinator.openDetails()
    }

    func presentCancelSheet() {
        coordinator.presentCancelSheet()
    }

    func primaryActionTapped() {
        guard !isProcessing else { return }
        isProcessing = true

        Task {
            if coordinator.offer.status == .visitStarted {
                try? await completeVisitUseCase.execute(offerId: coordinator.offer.id)
                coordinator.markVisitCompleted()
            } else {
                try? await startVisitUseCase.execute(offerId: coordinator.offer.id)
                coordinator.markVisitStarted()
            }
            isProcessing = false
        }
    }
}