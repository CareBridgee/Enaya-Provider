//
//  NearbyNurseServiceRequestResponse.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 07/08/2026.
//


import Foundation

struct NurseOfferRequestDTO: Encodable {
    let serviceRequestId: String
    let nurseId: String
    let proposedPrice: Double
    let proposedDate: String
    let proposedTime: String
    let message: String?
    
}
// MARK: - POST /nurse-offers (Response)
struct NurseOfferResponseDTO: Decodable {
    let id: String
    let serviceRequestId: String
    let status: String
}
