//
//  ServiceRequestDetailsResponseDTO.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 08/08/2026.
//


// ServiceRequestDetailsResponseDTO.swift

import Foundation

struct ServiceRequestDetailsResponseDTO: Decodable {
    let serviceRequestId: String
    let serviceType: ServiceTypeDetailsDTO
    let profile: ProfileDetailsDTO
    let nurse: NurseDetailsDTO?
    let serviceDescription: String?
    let preferredDate: String?
    let preferredTime: String? 
    let durationMinutes: Int?
    let status: String
    let latitude: Double
    let longitude: Double
    let distanceKm: Double?
    let createdAt: String?
    let offers: [OfferDetailsDTO]?
}

struct ServiceTypeDetailsDTO: Decodable {
    let id: String
    let name: String
    let basePrice: Double
    let estimatedDurationMinutes: Int
}

struct ProfileDetailsDTO: Decodable {
    let id: String
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let profileImageUrl: String?
}

struct NurseDetailsDTO: Decodable {
    let id: String
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let profileImageUrl: String?
    let ratingAvg: Double?
    let totalReviews: Int?
}

struct OfferDetailsDTO: Decodable {
    let id: String
    let serviceRequestId: String
    let proposedPrice: Double
    let proposedDate: String?
    let proposedTime: String? // 👈 String
    let message: String?
    let status: String
}
