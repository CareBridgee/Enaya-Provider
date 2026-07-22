//
//  Gender.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import Foundation

enum Gender: String, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    var id: Self { self }
}

struct PersonalInfo {
    var profilePhotoData: Data? = nil
    var firstName = ""
    var lastName = ""
    var dateOfBirth: Date? = nil
    var nationalId = ""
    var gender: Gender? = nil
}