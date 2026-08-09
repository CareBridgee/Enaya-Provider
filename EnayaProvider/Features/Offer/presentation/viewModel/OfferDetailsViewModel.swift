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
    @Published var requestProfile: ServiceRequestProfileResponseDTO?
    @Published var errorMessage: String?
    @Published var showPhoneAlert = false
       @Published var phoneAlertMessage = ""
    private let reservationId: String
    private let coordinator: OfferCoordinator
    private let fetchDetailsUseCase: FetchServiceRequestDetailsUseCase
    private let fetchProfileUseCase: FetchServiceRequestProfileUseCase 

    init(
        reservationId: String,
        coordinator: OfferCoordinator,
        fetchDetailsUseCase: FetchServiceRequestDetailsUseCase,
        fetchProfileUseCase: FetchServiceRequestProfileUseCase
    ) {
        self.reservationId = reservationId
        self.coordinator = coordinator
        self.fetchDetailsUseCase = fetchDetailsUseCase
        self.fetchProfileUseCase = fetchProfileUseCase
    }

    func fetchData() async {
            isLoading = true
            errorMessage = nil
            do {
                async let details = fetchDetailsUseCase.execute(requestId: reservationId)
                async let profile = fetchProfileUseCase.execute(serviceRequestId: reservationId)
                
                self.requestDetails = try await details
                self.requestProfile = try await profile
                
                print("✅ [OfferDetailsVM] Details Fetched Successfully!")
                print("🟢 [Details] Preferred Date: \(String(describing: requestDetails?.preferredDate)) | Time: \(String(describing: requestDetails?.preferredTime))")
                print("🟢 [Details] Accepted Offer Date: \(String(describing: requestDetails?.offers?.first?.proposedDate))")
                print("🔵 [Profile] DOB (for age): \(String(describing: requestProfile?.patient.dateOfBirth))")
                print("🔵 [Profile] Address Object: \(String(describing: requestProfile?.address))")
                
            } catch {
                print("🔴 [OfferDetailsVM] Parsing Error: \(error)")
                errorMessage = "Failed to load live details: \(error.localizedDescription)"
            }
            isLoading = false
        }

        var scheduledDateText: String {
            let dateStr = requestDetails?.preferredDate ?? requestDetails?.offers?.first(where: { $0.status == "ACCEPTED" })?.proposedDate ?? ""
            guard !dateStr.isEmpty else { return "TBD" }
            
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd"
            guard let date = inputFormatter.date(from: dateStr) else { return dateStr }
            
            let outputFormatter = DateFormatter()
            if Calendar.current.isDateInToday(date) {
                outputFormatter.dateFormat = "'Today', MMM d"
            } else {
                outputFormatter.dateFormat = "MMM d"
            }
            return outputFormatter.string(from: date)
        }
        
        var scheduledTimeText: String {
            let timeStr = requestDetails?.preferredTime ?? requestDetails?.offers?.first(where: { $0.status == "ACCEPTED" })?.proposedTime ?? ""
            guard !timeStr.isEmpty else { return "TBD" }
            
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = timeStr.count > 5 ? "HH:mm:ss" : "HH:mm"
            guard let date = inputFormatter.date(from: timeStr) else { return timeStr }
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "h:mm a"
            return outputFormatter.string(from: date)
        }

    // MARK: - Computed Properties
    var patientFullName: String {
        guard let p = requestProfile?.patient else { return "Unknown Patient" }
        return "\(p.firstName) \(p.lastName)".trimmingCharacters(in: .whitespaces)
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
        requestProfile?.patient.profileImageUrl ?? requestDetails?.profile.profileImageUrl
    }
    
    var serviceName: String {
        requestDetails?.serviceType.name ?? "Service"
    }
    
    var durationMinutes: Int {
        requestDetails?.durationMinutes ?? requestDetails?.serviceType.estimatedDurationMinutes ?? 0
    }
    
    
    
    var totalAmount: Double {
        requestDetails?.offers?.first(where: { $0.status == "ACCEPTED" })?.proposedPrice ?? 0.0
    }
    
    var fullAddressText: String {
        requestProfile?.address?.fullAddressText ?? "Address details unavailable"
    }
    
    var addressLine: String {
        requestProfile?.address?.formattedLine ?? "Address unavailable"
    }
    
    var addressDetail: String {
        requestProfile?.address?.formattedDetail ?? ""
    }

    func copyAddressTapped() {
        UIPasteboard.general.string = fullAddressText
    }

    func viewPatientSummaryTapped() {}

    func callPatientTapped() {
           let phone = requestProfile?.patientPhoneNumber ?? requestDetails?.profile.phoneNumber ?? ""
           
           guard !phone.isEmpty, let url = URL(string: "tel://\(phone)") else {
               phoneAlertMessage = "Phone number is not available."
               showPhoneAlert = true
               return
           }
           
           if UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url)
           } else {
               UIPasteboard.general.string = phone
               phoneAlertMessage = "Calls not supported here. Patient's number \(phone) copied to clipboard."
               showPhoneAlert = true
           }
       }


    func openInMapsTapped() {
        guard let lat = requestDetails?.latitude, let lng = requestDetails?.longitude else { return }
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = fullAddressText
        mapItem.openInMaps()
    }
}
