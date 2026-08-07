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
    let preferredTime: PreferredTimeDTO?
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

struct ServiceRequestProfileResponseDTO: Decodable {
    let serviceRequestId: String
    let serviceTypeId: String
    let serviceName: String
    let serviceDescription: String?
    let preferredDate: String?
    let preferredTime: PreferredTimeDTO?
    let status: String
    let estimatedPrice: Double?
    let createdAt: String?
    let patient: PatientProfileDTO
    let patientPhoneNumber: String?
    let address: ServiceAddressDTO?
}

struct PreferredTimeDTO: Decodable {
    let hour: Int
    let minute: Int
    let second: Int?
    let nano: Int?
}

struct PatientProfileDTO: Decodable {
    let profileId: String
    let firstName: String
    let lastName: String
    let dateOfBirth: String?
    let gender: String?
}

struct ServiceAddressDTO: Decodable {
    let country: String?
    let city: String?
    let area: String?
    let street: String?
    let buildingNumber: String?
    let apartmentNumber: String?

    var formattedLine: String {
        [street, buildingNumber].compactMap { $0 }.joined(separator: " ")
    }

    var formattedDetail: String {
        [apartmentNumber.map { "Apt \($0)" }, area, city, country].compactMap { $0 }.joined(separator: ", ")
    }

    var fullAddressText: String {
        [formattedLine, formattedDetail].filter { !$0.isEmpty }.joined(separator: ", ")
    }
}
