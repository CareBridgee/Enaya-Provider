//
//  CancelJobRequestUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import Foundation

protocol CancelJobRequestUseCaseProtocol {
    func execute(id: UUID) async throws
}


struct CancelJobRequestUseCase {
    let repo: HomeRepositoryProtocol
    func execute(offerId: String) async throws { try await repo.cancelOffer(offerId: offerId) }
}
