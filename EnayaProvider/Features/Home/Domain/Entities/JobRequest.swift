//
//  JobRequest.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//

import Foundation

struct JobRequest: Identifiable, Equatable {
    enum Status: Equatable {
        case negotiating
        case pending
    }

    let id: UUID
    let patientLabel: String
    let distanceText: String
    let serviceName: String
    let estimatedPrice: Decimal
    let minPrice: Decimal
    let maxPrice: Decimal
    var proposedPrice: Decimal
    var status: Status
}

extension JobRequest {
    // Default mock
    static func mock() -> JobRequest { mock1() }
    
    // First Request
    static func mock1() -> JobRequest {
        JobRequest(
            id: UUID(),
            patientLabel: "Anonymous Patient",
            distanceText: "2.4 miles away",
            serviceName: "Injection Service",
            estimatedPrice: 85,
            minPrice: 50,
            maxPrice: 120,
            proposedPrice: 85,
            status: .negotiating
        )
    }
    
    // Second Request
    static func mock2() -> JobRequest {
        JobRequest(
            id: UUID(),
            patientLabel: "Sarah Jenkins",
            distanceText: "1.2 miles away",
            serviceName: "Wound Care",
            estimatedPrice: 120,
            minPrice: 90,
            maxPrice: 150,
            proposedPrice: 120,
            status: .negotiating
        )
    }
}
