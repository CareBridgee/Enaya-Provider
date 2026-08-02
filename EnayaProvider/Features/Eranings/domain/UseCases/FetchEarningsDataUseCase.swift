//
//  FetchEarningsDataUseCase.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation

// Implementations for the 4 fetch methods mapping to the repository
public struct FetchEarningsDataUseCase {
    let repository: EarningsRepositoryProtocol
    func fetchSummary() async throws -> EarningsSummary { try await repository.fetchEarningsSummary() }
    func fetchJobs() async throws -> [JobEarning] { try await repository.fetchJobEarnings() }
    func fetchPayoutSummary() async throws -> PayoutSummary { try await repository.fetchPayoutSummary() }
    func fetchPayoutHistory() async throws -> [PayoutTransaction] { try await repository.fetchPayoutHistory() }
}