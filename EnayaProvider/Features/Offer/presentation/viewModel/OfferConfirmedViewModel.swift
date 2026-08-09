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

    private let reservationId: String
    private let coordinator: OfferCoordinator
    private let fetchDetailsUseCase: FetchServiceRequestDetailsUseCase
    private let fetchProfileUseCase: FetchServiceRequestProfileUseCaseProtocol
    private let completeVisitUseCase: CompleteVisitUseCaseProtocol

    init(
        reservationId: String,
        coordinator: OfferCoordinator,
        fetchDetailsUseCase: FetchServiceRequestDetailsUseCase,
        fetchProfileUseCase: FetchServiceRequestProfileUseCaseProtocol,
        completeVisitUseCase: CompleteVisitUseCaseProtocol
    ) {
        self.reservationId = reservationId
        self.coordinator = coordinator
        self.fetchDetailsUseCase = fetchDetailsUseCase
        self.fetchProfileUseCase = fetchProfileUseCase
        self.completeVisitUseCase = completeVisitUseCase
    }

    func loadDetails() async {
        isLoading = true
        do {
            async let details = fetchDetailsUseCase.execute(requestId: reservationId)
            async let profile = fetchProfileUseCase.execute(serviceRequestId: reservationId)
            self.liveDetails = try await details
            self.requestProfile = try await profile
        } catch {
            print("Failed to load details or profile: \(error)")
        }
        isLoading = false
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

    func openDetails() { coordinator.openDetails() }
    func presentCancelSheet() { coordinator.presentCancelSheet() }
    
    func callPatientTapped() {
        let phone = requestProfile?.patientPhoneNumber ?? liveDetails?.profile.phoneNumber ?? ""
        
        guard !phone.isEmpty, let url = URL(string: "tel://\(phone)") else {
            phoneAlertMessage = "Phone number is not available."
            showPhoneAlert = true
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
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
        guard let code = QRDecoder.decode(image: image) else {
            displayTemporaryError("No valid QR code found in the image. Please ensure the QR is clear and try again.")
            return
        }
        
        errorMessage = nil
        completeVisit(with: code)
    }
    
    private func completeVisit(with code: String) {
        guard !isProcessing else { return }
        isProcessing = true
        Task {
            do {
                try await completeVisitUseCase.execute(requestId: reservationId, visitCode: code)
                coordinator.markVisitCompleted()
            } catch {
                displayTemporaryError("Failed to complete visit: \(error.localizedDescription)")
            }
            isProcessing = false
        }
    }
}

