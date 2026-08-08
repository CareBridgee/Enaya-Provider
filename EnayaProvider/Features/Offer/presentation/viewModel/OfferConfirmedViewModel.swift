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
    @Published var liveDetails: ServiceRequestDetailsResponseDTO?
    @Published var isLoading = true
    @Published var isVisitStarted = false

    private let reservationId: String
    private let coordinator: OfferCoordinator
    private let fetchDetailsUseCase: FetchServiceRequestDetailsUseCase
    private let startVisitUseCase: StartVisitUseCaseProtocol
    private let completeVisitUseCase: CompleteVisitUseCaseProtocol

    init(
        reservationId: String,
        coordinator: OfferCoordinator,
        fetchDetailsUseCase: FetchServiceRequestDetailsUseCase,
        startVisitUseCase: StartVisitUseCaseProtocol,
        completeVisitUseCase: CompleteVisitUseCaseProtocol
    ) {
        self.reservationId = reservationId
        self.coordinator = coordinator
        self.fetchDetailsUseCase = fetchDetailsUseCase
        self.startVisitUseCase = startVisitUseCase
        self.completeVisitUseCase = completeVisitUseCase
    }

    func loadDetails() async {
        isLoading = true
        do {
            liveDetails = try await fetchDetailsUseCase.execute(requestId: reservationId)
            print("📸 [OfferConfirmedVM] Fetched Live Details | Patient Image URL: \(liveDetails?.profile.profileImageUrl ?? "nil")")
        } catch {
            print("Failed to load details: \(error)")
        }
        isLoading = false
    }

    var patientName: String {
            guard let p = liveDetails?.profile else { return "Loading..." }
            return "\(p.firstName ?? "") \(p.lastName ?? "")".trimmingCharacters(in: .whitespaces)
        }
    var canCancel: Bool { !isVisitStarted }

    func openDetails() {
        coordinator.openDetails()
    }

    func presentCancelSheet() {
        coordinator.presentCancelSheet()
    }

    var titleText: String {
        isVisitStarted ? "Visit Started" : "Offer Confirmed!"
    }

    var subtitleText: String {
        isVisitStarted
            ? "You've arrived and the care session is now underway."
            : "Your patient is waiting for you"
    }

    var actionButtonTitle: String {
        isVisitStarted ? "Complete Visit" : "Show Scan QR Code"
    }

   
    func primaryActionTapped() {
        guard !isProcessing else { return }
        isProcessing = true

        Task {
            do {
                if isVisitStarted {
                
                    try await completeVisitUseCase.execute(requestId: reservationId, visitCode: "12345678")
                    coordinator.markVisitCompleted()
                } else {
                    try await startVisitUseCase.execute(requestId: reservationId)
                    isVisitStarted = true
                    coordinator.markVisitStarted()
                }
            } catch {
                print("Error updating visit status: \(error)")
            }
            isProcessing = false
        }
    }
   
        
        var patientImageUrl: String? {
            liveDetails?.profile.profileImageUrl
        }
        
        var serviceName: String {
            liveDetails?.serviceType.name ?? "Loading..."
        }
        
        var distanceText: String {
            guard let dist = liveDetails?.distanceKm else { return "-- km" }
            return String(format: "%.1f km", dist)
        }
        
        var estimatedArrivalText: String {
            guard let timeStr = liveDetails?.preferredTime else { return "TBD" }
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "HH:mm"
            guard let date = inputFormatter.date(from: timeStr) else { return timeStr }
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "h:mm a"
            return outputFormatter.string(from: date)
        }

     
}
