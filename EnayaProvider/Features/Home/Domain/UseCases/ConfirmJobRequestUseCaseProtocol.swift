//
//  ConfirmJobRequestUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import Foundation

struct SubmitOfferUseCase {
    let repo: HomeRepositoryProtocol
    func execute(request: JobRequest, price: Decimal) async throws -> String {
        try await repo.submitOffer(for: request, proposedPrice: price)
    }
}
