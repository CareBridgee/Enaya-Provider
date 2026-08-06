//
//  NurseResponseDTO.swift
//  EnayaProvider
//
//  Created by Mohamed Ayman on 05/08/2026.
//

import Foundation

/// Full response for GET /api/v1/nurses/{id}
struct NurseResponseDTO: Decodable {
    let id: String
    let userId: String
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let nationalId: String?
    let nationalIdFrontUrl: String?
    let nationalIdBackUrl: String?
    let licenseImageUrl: String?
    let professionalCertificateUrl: String?
    let specialization: String?
    let yearsOfExperience: Int?
    let bio: String?
    let ratingAvg: Double
    let totalReviews: Int
    let verificationStatus: String
    let rejectionReason: String?
    let rejectionDetails: NurseRejectionDetailsDTO?
    let services: [NurseServiceDTO]?
}

struct NurseRejectionDetailsDTO: Decodable {
    let overallReason: String?
    let failedSteps: [NurseFailedStepDTO]?
}

struct NurseFailedStepDTO: Decodable {
    let step: String
    let reason: String
}

struct NurseServiceDTO: Decodable {
    let id: String
    let serviceTypeId: String
    let serviceName: String
    let serviceDescription: String?
    let basePrice: Double
    let isActive: Bool
}
