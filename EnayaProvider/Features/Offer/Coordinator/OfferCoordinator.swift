//
//  OfferCoordinator.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation
import SwiftUI

@MainActor
final class OfferCoordinator: ObservableObject {

    enum Phase {
        case active
        case completed
    }

    @Published private(set) var offer: ConfirmedOffer
    @Published var phase: Phase = .active
    @Published var path = NavigationPath()
    @Published var isShowingCancelSheet = false

    init(offer: ConfirmedOffer) {
        self.offer = offer
    }

    func openDetails() {
        path.append(OfferRoute.details)
    }

    func markVisitStarted() {
        offer.status = .visitStarted
    }

    func markVisitCompleted() {
        offer.status = .completed
        phase = .completed
    }

    func presentCancelSheet() {
        isShowingCancelSheet = true
    }

    func dismissCancelSheet() {
        isShowingCancelSheet = false
    }

    func markCancelled() {
        offer.status = .cancelled
    }
}
