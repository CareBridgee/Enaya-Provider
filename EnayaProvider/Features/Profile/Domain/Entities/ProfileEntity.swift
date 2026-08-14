//
//  ProfileEntity.swift
//  EnayaProvider
//
//  Created by AI.
//

import Foundation

struct ProfileEntity: Hashable {
    let id: String
    let firstName: String?
    let lastName: String?
    let profileImageUrl: String?
    let specialization: String?
    let ratingAvg: Double
    let totalReviews: Int
    let yearsOfExperience: Int
    let bio: String?
    let services: [String]
    
    // Professional Documents
    let nationalIdFrontUrl: String?
    let nationalIdBackUrl: String?
    let licenseImageUrl: String?
    let professionalCertificateUrl: String?
    let verificationStatus: String
    
    var fullName: String {
        let first = firstName ?? ""
        let last = lastName ?? ""
        return [first, last].filter { !$0.isEmpty }.joined(separator: " ")
    }
}
