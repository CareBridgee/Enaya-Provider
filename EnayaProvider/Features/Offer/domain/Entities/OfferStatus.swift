//
//  OfferStatus.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation

enum OfferStatus: Equatable {
    case confirmed
    case visitStarted
    case completed
    case cancelled
}

struct OfferPatient: Equatable {
    let name: String
    let ageText: String?
}

struct OfferAddress: Equatable {
    let line: String
    let detail: String
    let latitude: Double
    let longitude: Double

    var fullText: String { "\(line), \(detail)" }
}

struct ConfirmedOffer: Identifiable, Equatable {
    let id: UUID
    var patient: OfferPatient
    var serviceName: String
    var serviceIcon: String
    var distanceText: String
    var estimatedArrivalText: String
    var scheduledDateText: String
    var scheduledTimeText: String
    var durationMinutes: Int
    var address: OfferAddress
    var totalAmount: Decimal
    var providerPayoutAmount: Decimal
    var completedDateText: String
    var status: OfferStatus
}

enum CancellationReason: CaseIterable, Identifiable, Equatable {
    case vehicleIssue
    case personalEmergency
    case locationInaccessible
    case safetyConcern
    case incorrectPatientDetails
    case inappropriateConduct
    case other

    var id: Self { self }

    var title: String {
        switch self {
        case .vehicleIssue: return "Vehicle / Transportation issue"
        case .personalEmergency: return "Personal / Family Emergency"
        case .locationInaccessible: return "Patient's Location is Inaccessible"
        case .safetyConcern: return "Safety Concern at Patient Location"
        case .incorrectPatientDetails: return "Incorrect Patient Details"
        case .inappropriateConduct: return "Inappropriate Patient Conduct (previous experience)"
        case .other: return "Other reason (please describe)"
        }
    }
}