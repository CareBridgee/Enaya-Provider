//
//  Gender.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import Foundation

enum Gender: String, CaseIterable, Identifiable ,Decodable{
    case male = "MALE"
    case female = "FEMALE"
    var id: Self { self }
}

struct PersonalInfo {
    var profilePhotoData: Data? = nil
    var firstName = ""
    var lastName = ""
    var dateOfBirth: Date? = nil
    var nationalId = ""
    var licenseNumber = ""
    var gender: Gender? = nil
}
