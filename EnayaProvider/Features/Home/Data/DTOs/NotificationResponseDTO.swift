//
//  NotificationResponseDTO.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 07/08/2026.
//


import Foundation


struct NotificationResponseDTO: Decodable {
    let id: String
    let userId: String
    let title: String
    let message: String
    let type: String
    let isRead: Bool
    let relatedEntityType: String?
    let relatedEntityId: String?
    let createdAt: String
    let updatedAt: String?
}

struct NotificationData: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
    let type: String
}
struct NearbyNurseServiceRequestResponse: Codable {
    let serviceRequestId: String
    let profileId: String
    let serviceTypeId: String
    let serviceName: String
    let serviceDescription: String?
    let preferredDate: String?
    let preferredTime: String?      
    let status: String
    let latitude: Double
    let longitude: Double
    let distanceKm: Double
    let estimatedPrice: Double?
    let createdAt: String?
}

struct AvailabilityRequestDTO: Encodable {
    let available: Bool
    let lat: Double?
    let lng: Double?
}
