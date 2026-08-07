//
//  NurseRegistrationResponseDTO.swift
//  EnayaProvider
//
//  Created by Mohamed Ayman on 05/08/2026.
//

import Foundation

struct NurseRegistrationResponseDTO: Decodable {
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
    let verificationStatus: String?
}
