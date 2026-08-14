//
//  GetNurseReviewsUseCase.swift
//  EnayaProvider
//
//  Created by AI.
//

import Foundation

protocol GetNurseReviewsUseCaseProtocol: Sendable {
    func execute(id: String, page: Int, size: Int) async throws -> PaginatedReviewsEntity
}

final class GetNurseReviewsUseCase: GetNurseReviewsUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol
    
    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: String, page: Int, size: Int) async throws -> PaginatedReviewsEntity {
        return try await repository.getReviews(id: id, page: page, size: size)
    }
}
