//
//  EarningsRepositoryImpl.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation

public final class EarningsRepositoryImpl: EarningsRepositoryProtocol {
    private let delay: UInt64 = 500_000_000

    public init() {}

    public func fetchEarningsSummary() async throws -> EarningsSummary {
        try await Task.sleep(nanoseconds: delay)
        return EarningsSummary(totalThisMonth: 4280.50, jobsCount: 34)
    }

    public func fetchJobEarnings() async throws -> [JobEarning] {
        try await Task.sleep(nanoseconds: delay)
        return [
            JobEarning(id: UUID(), serviceName: "Wound Care", patientName: "Eleanor Rigby", dateText: "Oct 24, 2023 • 2.5 hours", amount: 125.00, status: .completed, iconName: "bandage.fill"),
            JobEarning(id: UUID(), serviceName: "Health Assessment", patientName: "Arthur Dent", dateText: "Oct 23, 2023 • 1.0 hour", amount: 85.00, status: .completed, iconName: "waveform.path.ecg"),
            JobEarning(id: UUID(), serviceName: "Meds Management", patientName: "Sarah Connor", dateText: "Oct 22, 2023 • 1.5 hours", amount: 110.00, status: .processing, iconName: "pills.fill"),
            JobEarning(id: UUID(), serviceName: "Physical Therapy", patientName: "James Bond", dateText: "Oct 20, 2023 • 2.0 hours", amount: 150.00, status: .completed, iconName: "figure.walk"),
            JobEarning(id: UUID(), serviceName: "Elderly Companionship", patientName: "Rose Dawson", dateText: "Oct 19, 2023 • 4.0 hours", amount: 200.00, status: .canceled, iconName: "leaf.fill")
        ]
    }

    public func fetchPayoutSummary() async throws -> PayoutSummary {
        try await Task.sleep(nanoseconds: delay)
        return PayoutSummary(availableForPayout: 1248.50, pending: 320.00, thisMonth: 4850.00)
    }

    public func fetchPayoutHistory() async throws -> [PayoutTransaction] {
        try await Task.sleep(nanoseconds: delay)
        return [
            PayoutTransaction(id: UUID(), methodType: .bank, dateText: "Oct 24, 2023 • 09:15 AM", amount: 450.00, status: .pending),
            PayoutTransaction(id: UUID(), methodType: .wallet, dateText: "Oct 20, 2023 • 04:30 PM", amount: 1200.00, status: .completed),
            PayoutTransaction(id: UUID(), methodType: .bank, dateText: "Oct 15, 2023 • 11:00 AM", amount: 890.00, status: .completed),
            PayoutTransaction(id: UUID(), methodType: .instant, dateText: "Oct 12, 2023 • 08:45 AM", amount: 150.00, status: .failed),
            PayoutTransaction(id: UUID(), methodType: .bank, dateText: "Oct 05, 2023 • 02:20 PM", amount: 2100.00, status: .completed)
        ]
    }
}