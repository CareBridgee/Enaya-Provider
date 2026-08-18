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
    let serviceRequestId: String   // 👈 ADDED
    let rating: Int
    let reviewText: String?
    let isAnonymous: Bool
    let createdAt: Date
    var reviewerName: String       // 👈 CHANGED to var
    var reviewerImageUrl: String?  // 👈 ADDED
    let serviceName: String
}
