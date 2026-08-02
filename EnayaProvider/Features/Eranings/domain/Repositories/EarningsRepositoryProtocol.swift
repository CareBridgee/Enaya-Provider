//
//  EarningsRepositoryProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation

public protocol EarningsRepositoryProtocol {
    func fetchEarningsSummary() async throws -> EarningsSummary
    func fetchJobEarnings() async throws -> [JobEarning]
    func fetchPayoutSummary() async throws -> PayoutSummary
    func fetchPayoutHistory() async throws -> [PayoutTransaction]
}