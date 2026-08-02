//
//  VisitCompletedViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation

@MainActor
final class VisitCompletedViewModel: ObservableObject {

    private let coordinator: OfferCoordinator
    private let onReturnHome: () -> Void

    init(coordinator: OfferCoordinator, onReturnHome: @escaping () -> Void) {
        self.coordinator = coordinator
        self.onReturnHome = onReturnHome
    }

    var offer: ConfirmedOffer { coordinator.offer }

    func returnHomeTapped() {
        onReturnHome()
    }
}