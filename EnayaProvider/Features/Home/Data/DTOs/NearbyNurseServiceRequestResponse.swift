//
//  NearbyNurseServiceRequestResponse.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 07/08/2026.
//


import Foundation

struct NurseOfferRequestDTO: Codable {
    let serviceRequestId: String
    let proposedPrice: Double
    let proposedDate: String
    let proposedTime: String
    let message: String
}

struct NurseOfferResponseDTO: Codable {
    let id: String
    let serviceRequestId: String
    let status: String
}
