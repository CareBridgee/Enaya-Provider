//
//  OfferRepositoryProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation

protocol OfferRepositoryProtocol {
    func startVisit(offerId: UUID) async throws -> ConfirmedOffer
    func completeVisit(offerId: UUID) async throws -> ConfirmedOffer
    func cancelOffer(offerId: UUID, reason: CancellationReason, detail: String?) async throws
}