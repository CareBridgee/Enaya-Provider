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
        case cancelled
    }

    let id: UUID
    var patientLabel: String
    var patientImageUrl: String
    let distanceText: String
    let serviceName: String
    var estimatedPrice: Decimal
    var minPrice: Decimal
    var maxPrice: Decimal
    var proposedPrice: Decimal
    var status: Status
}

