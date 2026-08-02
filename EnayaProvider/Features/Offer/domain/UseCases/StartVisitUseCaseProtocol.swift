//
//  StartVisitUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation

protocol StartVisitUseCaseProtocol {
    func execute(offerId: UUID) async throws
}

struct StartVisitUseCase: StartVisitUseCaseProtocol {
    let repository: OfferRepositoryProtocol
    func execute(offerId: UUID) async throws {
        _ = try? await repository.startVisit(offerId: offerId)
    }
}

protocol CompleteVisitUseCaseProtocol {
    func execute(offerId: UUID) async throws
}

struct CompleteVisitUseCase: CompleteVisitUseCaseProtocol {
    let repository: OfferRepositoryProtocol
    func execute(offerId: UUID) async throws {
        _ = try? await repository.completeVisit(offerId: offerId)
    }
}

protocol CancelOfferUseCaseProtocol {
    func execute(offerId: UUID, reason: CancellationReason, detail: String?) async throws
}

struct CancelOfferUseCase: CancelOfferUseCaseProtocol {
    let repository: OfferRepositoryProtocol
    func execute(offerId: UUID, reason: CancellationReason, detail: String?) async throws {
        try await repository.cancelOffer(offerId: offerId, reason: reason, detail: detail)
    }
}