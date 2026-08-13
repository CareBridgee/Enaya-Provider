//
//  UserMeDTO.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 07/08/2026.
//


import Foundation

struct UserMeDTO: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let profileImageUrl: String?
    let defaultProfileId: String?
}

struct NurseInfoDTO: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let profileImageUrl: String?
    let ratingAvg: Double
    let totalReviews: Int
}
