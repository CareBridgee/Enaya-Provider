//
//  UploadedDocument.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import Foundation

struct UploadedDocument: Equatable {
    let fileName: String
    let data: Data
}

enum ExperienceRange: String, CaseIterable, Identifiable {
    case lessThanOne = "Less than 1 year"
    case oneToThree = "1 - 3 years"
    case threeToFive = "3 - 5 years"
    case fiveToTen = "5 - 10 years"
    case tenPlus = "10+ years"
    var id: Self { self }
}

enum NursingSpecialty: String, CaseIterable, Identifiable {
    case icu = "ICU"
    case pediatric = "Pediatric"
    case geriatric = "Geriatric"
    case oncology = "Oncology"
    case cardiac = "Cardiac"
    case general = "General Nursing"
    var id: Self { self }
}

struct ProfessionalInfo {
    var nationalIdDocument: UploadedDocument? = nil
    var nationalIdBackDocument: UploadedDocument? = nil
    var nursingLicenseDocument: UploadedDocument? = nil
    var professionalCertificateDocument: UploadedDocument? = nil
    var yearsOfExperience: ExperienceRange? = nil
    var primarySpecialty: NursingSpecialty? = nil
    var licenseNumber: String? = nil
    var bio: String? = nil
}