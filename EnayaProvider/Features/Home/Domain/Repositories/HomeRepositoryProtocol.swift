//
//  HomeRepositoryProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import Foundation

protocol HomeRepositoryProtocol {
    func fetchSummary() async throws -> ProviderHomeSummary
    func fetchAvailability() async throws -> ProviderAvailability
    func setAvailability(_ status: ProviderAvailability) async throws
    func fetchActiveJobRequest() async throws -> JobRequest?
    func confirmJobRequest(id: UUID, proposedPrice: Decimal) async throws -> JobRequest
    func cancelJobRequest(id: UUID) async throws
    func observeJobRequests() -> AsyncStream<[JobRequest]>
}
