//
//  OfferConfirmedViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
final class OfferConfirmedViewModel: ObservableObject {
    @Published private(set) var isProcessing = false
    @Published var liveDetails: ServiceRequestDetailsResponseDTO?
    @Published var requestProfile: ServiceRequestProfileResponseDTO?
    @Published var isLoading = true
    
    @Published var errorMessage: String?
    
    @Published var showPhoneAlert = false
    @Published var phoneAlertMessage = ""
    @Published var showPatientCancelledAlert = false
    
    private let reservationId: String
    private let coordinator: OfferCoordinator
    private let fetchDetailsUseCase: FetchServiceRequestDetailsUseCase
    private let fetchProfileUseCase: FetchServiceRequestProfileUseCaseProtocol
    private let completeVisitUseCase: CompleteVisitUseCaseProtocol
    private let observeReservationEventsUseCase: ObserveReservationEventsUseCaseProtocol
    private var socketTask: Task<Void, Never>?
    
    init(
        reservationId: String,
        coordinator: OfferCoordinator,
        fetchDetailsUseCase: FetchServiceRequestDetailsUseCase,
        fetchProfileUseCase: FetchServiceRequestProfileUseCaseProtocol,
        completeVisitUseCase: CompleteVisitUseCaseProtocol,
        observeReservationEventsUseCase: ObserveReservationEventsUseCaseProtocol
    ) {
        self.reservationId = reservationId
        self.coordinator = coordinator
        self.fetchDetailsUseCase = fetchDetailsUseCase
        self.fetchProfileUseCase = fetchProfileUseCase
        self.completeVisitUseCase = completeVisitUseCase
        self.observeReservationEventsUseCase = observeReservationEventsUseCase
    }

    func loadDetails() async {
        startObservingSocket()
        isLoading = true
        do {
            async let details = fetchDetailsUseCase.execute(requestId: reservationId)
            async let profile = fetchProfileUseCase.execute(serviceRequestId: reservationId)
            self.liveDetails = try await details
            self.requestProfile = try await profile
        } catch {
            print("Failed to load details or profile: \(error)")
            if !self.coordinator.isNurseCancelling {
                self.showPatientCancelledAlert = true
            }
        }
        isLoading = false
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
    
    // MARK: - View Data Properties
    var patientName: String {
        guard let p = liveDetails?.profile else { return "Loading..." }
        return "\(p.firstName ?? "") \(p.lastName ?? "")".trimmingCharacters(in: .whitespaces)
    }
    
    var patientAge: String? {
        guard let dobString = requestProfile?.patient.dateOfBirth else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let dob = formatter.date(from: dobString) else { return nil }
        let age = Calendar.current.dateComponents([.year], from: dob, to: Date()).year
        return age != nil ? "\(age!)" : nil
    }
    
    var patientImageUrl: String? {
        requestProfile?.patient.profileImageUrl ?? liveDetails?.profile.profileImageUrl
    }
    
    var serviceName: String { liveDetails?.serviceType.name ?? "Loading..." }
    
    var distanceText: String {
        guard let dist = liveDetails?.distanceKm else { return "-- km" }
        return String(format: "%.1f km", dist)
    }
    
    var estimatedArrivalText: String {
        let timeStr = liveDetails?.preferredTime ?? liveDetails?.offers?.first(where: { $0.status == "ACCEPTED" })?.proposedTime ?? ""
        guard !timeStr.isEmpty else { return "TBD" }
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = timeStr.count > 5 ? "HH:mm:ss" : "HH:mm"
        guard let date = inputFormatter.date(from: timeStr) else { return timeStr }
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        return outputFormatter.string(from: date)
    }

    func openDetails() {
        print("[OfferConfirmedViewModel] View Offer Details tapped")
        coordinator.openDetails()
    }

    func presentCancelSheet() {
        print("[OfferConfirmedViewModel] Cancel Visit button tapped")
        coordinator.presentCancelSheet()
    }
    
    func openChatTapped() {
        let phone = requestProfile?.patientPhoneNumber ?? liveDetails?.profile.phoneNumber ?? ""
        print("[OfferConfirmedViewModel] Open Chat tapped for patient: '\(patientName)', phone: '\(phone)'")
        coordinator.openChat(
            patientName: patientName,
            imageUrl: patientImageUrl,
            phone: phone
        )
    }
    
    func callPatientTapped() {
        let phone = requestProfile?.patientPhoneNumber ?? liveDetails?.profile.phoneNumber ?? ""
        print("[OfferConfirmedViewModel] Call Patient tapped for patient: '\(patientName)', phone: '\(phone)'")
        
        guard !phone.isEmpty, let url = URL(string: "tel://\(phone)") else {
            print("[OfferConfirmedViewModel] Error: Phone number is empty or invalid ('\(phone)')")
            phoneAlertMessage = "Phone number is not available."
            showPhoneAlert = true
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            print("[OfferConfirmedViewModel] Initiating phone call to '\(phone)'")
            UIApplication.shared.open(url)
        } else {
            print("[OfferConfirmedViewModel] Phone calls not supported on this device. Copying '\(phone)' to clipboard")
            UIPasteboard.general.string = phone
            phoneAlertMessage = "Calls are not supported on this device. Patient's number \(phone) has been copied to your clipboard."
            showPhoneAlert = true
        }
    }

    private func displayTemporaryError(_ message: String) {
        withAnimation { self.errorMessage = message }
        
        Task {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            if self.errorMessage == message {
                withAnimation { self.errorMessage = nil }
            }
        }
    }

    func processScannedImage(_ image: UIImage) {
        print("[OfferConfirmedViewModel] Processing scanned QR image...")
        guard let code = QRDecoder.decode(image: image) else {
            print("[OfferConfirmedViewModel] Error: Failed to decode QR code from image")
            displayTemporaryError("No valid QR code found in the image. Please ensure the QR is clear and try again.")
            return
        }
        
        print("[OfferConfirmedViewModel] QR code successfully decoded: '\(code)'")
        errorMessage = nil
        completeVisit(with: code)
    }
    
    private func completeVisit(with code: String) {
        guard !isProcessing else {
            print("[OfferConfirmedViewModel] Complete visit already in progress, skipping request")
            return
        }
        isProcessing = true
        print("[OfferConfirmedViewModel] Executing completeVisitUseCase with code: '\(code)'...")
        Task {
            do {
                try await completeVisitUseCase.execute(requestId: reservationId, visitCode: code)
                print("[OfferConfirmedViewModel] Visit completed successfully for reservationId: \(reservationId)")
                coordinator.markVisitCompleted()
            } catch {
                print("[OfferConfirmedViewModel] Error completing visit: \(error)")
                displayTemporaryError("Failed to complete visit: \(error.localizedDescription)")
            }
            isProcessing = false
        }
    }
    
    func handlePatientCancellationAcknowledged() {
        print("[OfferConfirmedViewModel] Patient cancellation alert acknowledged by user")
        coordinator.dismissEntireFlow()
    }

    deinit {
        socketTask?.cancel()
    }
}
