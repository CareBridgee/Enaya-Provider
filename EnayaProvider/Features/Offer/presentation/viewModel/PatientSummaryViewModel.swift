//
//  PatientSummaryViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 12/08/2026.
//


import Foundation
import SwiftUI

@MainActor
final class PatientSummaryViewModel: ObservableObject {
    @Published var showPatientCancelledAlert = false
    
    let profile: ServiceRequestProfileResponseDTO
    private let reservationId: String
    private let coordinator: OfferCoordinator
    private let observeReservationEventsUseCase: ObserveReservationEventsUseCaseProtocol
    private var socketTask: Task<Void, Never>?
    
    init(
        reservationId: String,
        profile: ServiceRequestProfileResponseDTO,
        coordinator: OfferCoordinator,
        observeReservationEventsUseCase: ObserveReservationEventsUseCaseProtocol
    ) {
        self.reservationId = reservationId
        self.profile = profile
        self.coordinator = coordinator
        self.observeReservationEventsUseCase = observeReservationEventsUseCase
        startObservingSocket()
    }
    
    private func startObservingSocket() {
        socketTask?.cancel()
        socketTask = Task { @MainActor in
            for await event in observeReservationEventsUseCase.execute(reservationId: reservationId) {
                if event.type.uppercased() == "REQUEST_CANCELLED" {
                    if !self.coordinator.isNurseCancelling {
                        self.showPatientCancelledAlert = true
                    }
                }
            }
        }
    }
    
    func handlePatientCancellationAcknowledged() {
        coordinator.dismissEntireFlow()
    }
    
    func callEmergencyContact(phone: String) {
        guard !phone.isEmpty, let url = URL(string: "tel://\(phone)") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    var patientName: String {
        "\(profile.patient.firstName) \(profile.patient.lastName)".trimmingCharacters(in: .whitespaces)
    }
    
    var age: String {
        guard let dobString = profile.patient.dateOfBirth else { return "--" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let dob = formatter.date(from: dobString) else { return "--" }
        let calcAge = Calendar.current.dateComponents([.year], from: dob, to: Date()).year
        return calcAge != nil ? "\(calcAge!)" : "--"
    }
    
    var gender: String {
        profile.patient.gender?.capitalized ?? "--"
    }
    
    var bloodType: String {
        profile.patient.bloodType ?? "--"
    }
    
    var height: String {
        guard let h = profile.patient.height else { return "--" }
        return "\(h) cm"
    }
    
    var weight: String {
        guard let w = profile.patient.weight else { return "--" }
        return "\(w) kg"
    }
    
    var mobility: String {
        profile.patient.mobilityStatus?.capitalized ?? "--"
    }
    
    var hasConditions: Bool {
        return !(profile.patient.medicalConditions?.isEmpty ?? true)
    }
    
    var hasAllergies: Bool {
        return !(profile.patient.allergies?.isEmpty ?? true)
    }
    
    var hasMedications: Bool {
        return !(profile.patient.medications?.isEmpty ?? true)
    }
    
    var hasHistory: Bool {
        return !(profile.patient.medicalHistory?.isEmpty ?? true)
    }
    
    var hasEmergencyContacts: Bool {
        return !(profile.patient.emergencyContacts?.isEmpty ?? true)
    }
    
    deinit {
        socketTask?.cancel()
    }
}
