//
//  OfferDetailsViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//

import Foundation
import UIKit
import MapKit

@MainActor
final class OfferDetailsViewModel: ObservableObject {
    @Published private(set) var isLoading = true
    @Published var requestDetails: ServiceRequestDetailsResponseDTO?
    @Published var errorMessage: String?
    
    private let reservationId: String
    private let fetchDetailsUseCase: FetchServiceRequestDetailsUseCase
    private let coordinator: OfferCoordinator

    init(reservationId: String, coordinator: OfferCoordinator, fetchDetailsUseCase: FetchServiceRequestDetailsUseCase) {
        self.reservationId = reservationId
        self.coordinator = coordinator
        self.fetchDetailsUseCase = fetchDetailsUseCase
    }

    func fetchDetails() async {
        isLoading = true
        errorMessage = nil
        do {
            requestDetails = try await fetchDetailsUseCase.execute(requestId: reservationId)
        } catch {
            errorMessage = "Failed to load actual details: \(error.localizedDescription)"
        }
        isLoading = false
    }


    var patientFullName: String {
        guard let p = requestDetails?.profile else { return "Unknown Patient" }
        return "\(p.firstName ?? "") \(p.lastName ?? "")".trimmingCharacters(in: .whitespaces)
    }
    
    var patientImageUrl: String? {
        requestDetails?.profile.profileImageUrl
    }
    
    var serviceName: String {
        requestDetails?.serviceType.name ?? "Service"
    }
    
    var durationMinutes: Int {
        requestDetails?.durationMinutes ?? 0
    }
    
    var scheduledDateText: String {
        guard let dateStr = requestDetails?.preferredDate else { return "TBD" }
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = inputFormatter.date(from: dateStr) else { return dateStr }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d"
        return outputFormatter.string(from: date)
    }
    
    var scheduledTimeText: String {
        guard let timeStr = requestDetails?.preferredTime else { return "TBD" }
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm"
        guard let date = inputFormatter.date(from: timeStr) else { return timeStr }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        return outputFormatter.string(from: date)
    }
    
    var totalAmount: Double {
        requestDetails?.offers?.first(where: { $0.status == "ACCEPTED" })?.proposedPrice ?? 0.0
    }
    
    var fullAddressText: String {
       
        return "Address details unavailable"
    }

    // MARK: - Actions

    func copyAddressTapped() {
        UIPasteboard.general.string = fullAddressText
    }

    func viewPatientSummaryTapped() {
    }

    func callPatientTapped() {
        guard let phoneNumber = requestDetails?.profile.phoneNumber,
              let url = URL(string: "tel://\(phoneNumber)") else { return }
        UIApplication.shared.open(url)
    }

    func openInMapsTapped() {
        guard let lat = requestDetails?.latitude, let lng = requestDetails?.longitude else { return }
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = fullAddressText
        mapItem.openInMaps()
    }
}
