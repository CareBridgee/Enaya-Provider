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
    @Published var isNurseCancelling = false
    
    let reservationId: String
    var onFinishFlow: (() -> Void)?
    
    init(reservationId: String) {
        self.reservationId = reservationId
    }
    
    func openDetails() {
        path.append(OfferRoute.details)
    }
    
    func openChat(patientName: String, imageUrl: String?, phone: String) {
        path.append(OfferRoute.chat(patientName: patientName, imageUrl: imageUrl, phone: phone))
    }
    
    func openPatientSummary(profile: ServiceRequestProfileResponseDTO) {
        path.append(OfferRoute.patientSummary(profile: profile))
    }
    
    func presentCancelSheet() {
        isShowingCancelSheet = true
    }
    
    func dismissCancelSheet() {
        isShowingCancelSheet = false
    }
    
    func dismissEntireFlow() {
        onFinishFlow?()
    }
    
    func markCancelled() {
    }
    
    func markVisitStarted() {
    }
    
    func markVisitCompleted() {
        phase = .completed
    }
}
