//
//  ServiceRequestDetailsResponseDTO.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 08/08/2026.
//


// ServiceRequestDetailsResponseDTO.swift

import Foundation


struct ServiceRequestDetailsResponseDTO: Decodable, Hashable, Equatable {
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

struct ServiceTypeDetailsDTO: Decodable, Hashable, Equatable {
    let id: String
    let name: String
    let basePrice: Double
    let estimatedDurationMinutes: Int
}

struct ProfileDetailsDTO: Decodable, Hashable, Equatable {
    let id: String
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let profileImageUrl: String?
}

struct NurseDetailsDTO: Decodable, Hashable, Equatable {
    let id: String
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let profileImageUrl: String?
    let ratingAvg: Double?
    let totalReviews: Int?
}

struct OfferDetailsDTO: Decodable, Hashable, Equatable {
    let id: String
    let serviceRequestId: String
    let proposedPrice: Double
    let proposedDate: String?
    let proposedTime: String?
    let message: String?
    let status: String
}

struct ServiceRequestProfileResponseDTO: Decodable, Hashable, Equatable {
    let serviceRequestId: String
    let serviceTypeId: String
    let serviceName: String
    let serviceDescription: String?
    let preferredDate: String?
    let preferredTime: String?
    let status: String
    let estimatedPrice: Double?
    let createdAt: String?
    let patient: PatientProfileDTO
    let patientPhoneNumber: String?
    let address: ServiceAddressDTO?
}

struct PatientProfileDTO: Decodable, Hashable, Equatable {
    let profileId: String
    let firstName: String
    let lastName: String
    let profileImageUrl: String?
    let dateOfBirth: String?
    let gender: String?
    let bloodType: String?
    let height: Int?
    let weight: Int?
    let mobilityStatus: String?
    let mobilityNotes: String?
    let previousSurgeries: String?
    let previousHospitalizations: String?
    let allergies: [String]?
    let medicalConditions: [String]?
    let medications: [String]?
    let medicalHistory: [MedicalHistoryDTO]?
    let emergencyContacts: [EmergencyContactDTO]?
}

struct MedicalHistoryDTO: Decodable, Hashable, Equatable, Identifiable {
    var id: String { type ?? UUID().uuidString }
    let type: String?
    let description: String?
}

struct EmergencyContactDTO: Decodable, Hashable, Equatable, Identifiable {
    var id: String { phoneNumber ?? UUID().uuidString }
    let name: String?
    let relationship: String?
    let phoneNumber: String?
}



struct ServiceAddressDTO: Decodable, Hashable, Equatable {
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






// MARK: - Address DTO
struct RequestAddressDTO: Decodable {
    let country: String?
    let city: String?
    let area: String?
    let street: String?
    let buildingNumber: String?
    let apartmentNumber: String?

    var fullAddressText: String {
        let components = [street, area, city, country].compactMap { $0 }.filter { !$0.isEmpty }
        return components.isEmpty ? "Address details unavailable" : components.joined(separator: ", ")
    }
    
    var formattedLine: String {
        let components = [street, area].compactMap { $0 }.filter { !$0.isEmpty }
        return components.isEmpty ? "Address unavailable" : components.joined(separator: ", ")
    }
    
    var formattedDetail: String {
        var details: [String] = []
        if let b = buildingNumber, !b.isEmpty { details.append("Bldg \(b)") }
        if let a = apartmentNumber, !a.isEmpty { details.append("Apt \(a)") }
        return details.joined(separator: ", ")
    }
}
