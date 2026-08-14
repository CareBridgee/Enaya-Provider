//
//  ReviewResponseDTO.swift
//  EnayaProvider
//
//  Created by AI.
//

import Foundation

struct PaginatedReviewsDTO: Codable {
    let totalElements: Int
    let totalPages: Int
    let pageable: PageableDTO
    let size: Int
    let content: [ReviewDTO]
    let number: Int
    let sort: SortDTO
    let first: Bool
    let last: Bool
    let numberOfElements: Int
    let empty: Bool
}

struct PageableDTO: Codable {
    let paged: Bool
    let pageNumber: Int
    let pageSize: Int
    let offset: Int
    let sort: SortDTO
    let unpaged: Bool
}

struct SortDTO: Codable {
    let sorted: Bool
    let empty: Bool
    let unsorted: Bool
}

struct ReviewDTO: Codable {
    let id: String
    let serviceRequestId: String
    let profileId: String
    let nurseId: String
    let rating: Int
    let reviewText: String?
    let isAnonymous: Bool
    let createdAt: String
    let updatedAt: String
}
