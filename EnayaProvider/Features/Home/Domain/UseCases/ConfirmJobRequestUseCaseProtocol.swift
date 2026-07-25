//
//  ConfirmJobRequestUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import Foundation

protocol ConfirmJobRequestUseCaseProtocol {
    func execute(request: JobRequest, proposedPrice: Decimal) async throws -> JobRequest
}

struct ConfirmJobRequestUseCase: ConfirmJobRequestUseCaseProtocol {
    private let repository: HomeRepositoryProtocol

    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }

    func execute(request: JobRequest, proposedPrice: Decimal) async throws -> JobRequest {
        guard proposedPrice >= request.minPrice, proposedPrice <= request.maxPrice else {
            throw HomeError.priceOutOfRange(min: request.minPrice, max: request.maxPrice)
        }
        return try await repository.confirmJobRequest(id: request.id, proposedPrice: proposedPrice)
    }
}