//
//  NurseOfferHistoryDTO.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 14/08/2026.
//
//  Mirrors the response schema of GET /api/v1/service-requests/nurse/history.
//  (file name kept for project-reference stability)
//

import Foundation

// GET /api/v1/service-requests/nurse/history
struct NurseServiceRequestHistoryDTO: Decodable {
    let serviceRequestId: String
    let serviceTypeId: String
    let serviceName: String
    let estimatedDurationMinutes: Int?
    let patientProfileId: String
    let patientFirstName: String?
    let patientLastName: String?
    let patientPhoneNumber: String?
    let patientProfileImageUrl: String?
    let serviceDescription: String?
    let preferredDate: String?
    let preferredTime: String?
    let status: NurseServiceRequestStatus
    let estimatedPrice: Double?
    let createdAt: Date?
    let updatedAt: Date?
}
