//
//  OfferRepositoryImpl.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation

final class OfferRepositoryImpl: OfferRepositoryProtocol {
    private let simulatedDelayNanoseconds: UInt64 = 900_000_000

    func startVisit(offerId: UUID) async throws -> ConfirmedOffer {
        try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        // Mocked: the real API call will update and return the offer's new status.
        throw OfferRepositoryMockError.useLocalUpdate
    }

    func completeVisit(offerId: UUID) async throws -> ConfirmedOffer {
        try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        throw OfferRepositoryMockError.useLocalUpdate
    }

    func cancelOffer(offerId: UUID, reason: CancellationReason, detail: String?) async throws {
        try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
    }
}

/// Marks paths where there's no real backend response to shape yet — the caller
/// applies the status transition locally instead of trusting a mocked payload.
enum OfferRepositoryMockError: Error {
    case useLocalUpdate
}