//
//  UpdateProfileRequestDTO.swift
//  EnayaProvider
//
//  Created by Mohamed Ayman on 05/08/2026.
//

import Foundation

struct UpdateProfileRequestDTO: Encodable {
    let firstName: String
    let lastName: String
    let email: String?
    let dateOfBirth: String? // "YYYY-MM-DD"
    let gender: String?
    let profileImageUrl: String?
}
