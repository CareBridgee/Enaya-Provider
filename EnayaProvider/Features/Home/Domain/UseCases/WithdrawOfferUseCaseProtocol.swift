//
//  WithdrawOfferUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 12/08/2026.
//


import Foundation


protocol WithdrawOfferUseCaseProtocol {
    func execute(offerId: String) async throws
}

struct WithdrawOfferUseCase: WithdrawOfferUseCaseProtocol {
    let repo: HomeRepositoryProtocol
    
    func execute(offerId: String) async throws {
        try await repo.withdrawOffer(offerId: offerId)
    }
}
