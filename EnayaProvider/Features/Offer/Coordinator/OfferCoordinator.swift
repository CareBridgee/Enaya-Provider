//
//  OfferCoordinator.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation
import SwiftUI

enum OfferPhase {
    case active
    case completed
}

@MainActor
final class OfferCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var phase: OfferPhase = .active
    @Published var isShowingCancelSheet = false
    
    let reservationId: String
    
    init(reservationId: String) {
        self.reservationId = reservationId
    }
    
    func openDetails() {
        path.append(OfferRoute.details)
    }
    
    func presentCancelSheet() {
        isShowingCancelSheet = true
    }
    
    func dismissCancelSheet() {
        isShowingCancelSheet = false
    }
    
    func markCancelled() {
        // Will close the whole flow via onFinished
    }
    
    func markVisitStarted() {
        // Update local state if needed
    }
    
    func markVisitCompleted() {
        phase = .completed
    }
}
