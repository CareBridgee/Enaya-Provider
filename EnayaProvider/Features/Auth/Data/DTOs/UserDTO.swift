//
//  UserDTO.swift
//  Carely
//
//  Created by Mohamed Ayman on 25/07/2026.
//

import Foundation

struct UserDTO: Decodable {
    let id: String
    let phoneNumber: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let dateOfBirth: String?
    let gender: Gender?
    let profileImageUrl: String?
    let isDeleted: Bool
    let createdAt: Date
    let updatedAt: Date
    let lastLoginAt: Date?
    let defaultProfileId: String?
    let nurse: NurseDTO?
}
struct NurseDTO: Decodable {
    let id: String
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
    let rejectionDetails: String?
}
