//
//  NurseOfferResponseDTO.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 12/08/2026.
//



import Foundation

struct OfferResponseDTO: Codable {
    let id: String
    let serviceRequestId: String
    let nurse: NurseSummaryDTO
    let status: String
    let createdAt: String
}

struct NurseSummaryDTO: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let profileImageUrl: String?
    let ratingAvg: Double?
    let totalReviews: Int?
}
