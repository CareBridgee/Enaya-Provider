//
//  RegisterNurseRequest.swift
//  EnayaProvider
//

import Foundation

struct RegisterNurseRequest {
    let nationalId: String
    let licenseNumber: String
    let specialization: String
    let yearsOfExperience: Int
    let bio: String?
    let nationalIdFront: Data
    let nationalIdBack: Data
    let licenseImage: Data
    let professionalCertificate: Data
}
