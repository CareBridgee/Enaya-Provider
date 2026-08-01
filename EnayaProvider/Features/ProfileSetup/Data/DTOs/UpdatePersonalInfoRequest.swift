//
//  UpdatePersonalInfoRequest.swift
//  EnayaProvider
//

import Foundation

struct UpdatePersonalInfoRequest: Encodable {
    let firstName: String
    let lastName: String
    let email: String?
    let dateOfBirth: String // Format: YYYY-MM-DD
    let gender: Gender
    let profileImageUrl: String?
}
