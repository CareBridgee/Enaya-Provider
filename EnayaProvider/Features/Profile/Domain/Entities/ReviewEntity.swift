//
//  ReviewEntity.swift
//  EnayaProvider
//
//  Created by AI.
//

import Foundation

struct PaginatedReviewsEntity: Equatable, Sendable {
    let totalElements: Int
    let totalPages: Int
    let pageNumber: Int
    let pageSize: Int
    let isLastPage: Bool
    let reviews: [ReviewEntity]
}

struct ReviewEntity: Equatable, Identifiable, Sendable {
    let id: String
    let rating: Int
    let reviewText: String?
    let isAnonymous: Bool
    let createdAt: Date
    let reviewerName: String
    let serviceName: String
}
