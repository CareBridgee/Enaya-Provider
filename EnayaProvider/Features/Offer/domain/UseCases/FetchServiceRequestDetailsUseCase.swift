//
//  FetchServiceRequestDetailsUseCase.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 08/08/2026.
//


struct FetchServiceRequestDetailsUseCase {
    let repo: OfferRepositoryProtocol
    func execute(requestId: String) async throws -> ServiceRequestDetailsResponseDTO {
        return try await repo.fetchRequestDetails(requestId: requestId)
    }
}

struct CancelServiceRequestUseCase {
    let repo: OfferRepositoryProtocol
    func execute(requestId: String) async throws {
        try await repo.cancelServiceRequest(requestId: requestId)
    }
}