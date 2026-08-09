//
//  ServiceRequestProfileResponseDTO.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 07/08/2026.
//

import Foundation

// MARK: - Preview DTO (For Feed / Unassigned Nurses)
struct ServiceRequestPreviewResponseDTO: Decodable {
    let serviceRequestId: String
    let serviceTypeId: String
    let serviceName: String
    let serviceDescription: String?
    let preferredDate: String?
    let preferredTime: String?
    let status: String
    let estimatedPrice: Double?
    let createdAt: String?
    let patient: PreviewPatientDTO?
}

struct PreviewPatientDTO: Decodable {
    let profileId: String
    let firstName: String?
    let lastName: String?
    let dateOfBirth: String?
    let gender: String?
    let bloodType: String?
    let height: Double?
    let weight: Double?
    let mobilityStatus: String?
    let profileImageUrl: String?
    let mobilityNotes: String?
    let previousSurgeries: String?
    let previousHospitalizations: String?
    let allergies: [String]?
    let medicalConditions: [String]?
    let medications: [String]?
    let medicalHistory: [MedicalHistoryItemDTO]?
    let emergencyContacts: [EmergencyContactDTO]?
}

struct MedicalHistoryItemDTO: Decodable {
    let type: String?
    let description: String?
}

struct EmergencyContactDTO: Decodable {
    let name: String?
    let relationship: String?
    let phoneNumber: String?
}

