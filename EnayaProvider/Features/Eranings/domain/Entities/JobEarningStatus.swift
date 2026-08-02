//
//  JobEarningStatus.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation

public enum JobEarningStatus: String, CaseIterable, Equatable {
    case completed = "Completed"
    case processing = "Processing"
    case canceled = "Canceled"
}

public enum PayoutTransactionStatus: String, CaseIterable, Equatable {
    case completed = "COMPLETED"
    case pending = "PENDING"
    case failed = "FAILED"
}

public enum PayoutMethodType: String, Equatable {
    case bank = "Bank Transfer"
    case wallet = "Wallet Transfer"
    case instant = "Instant Pay"
    
    var icon: String {
        switch self {
        case .bank: return "building.columns.fill"
        case .wallet: return "wallet.pass.fill"
        case .instant: return "banknote.fill"
        }
    }
}

public struct EarningsSummary: Equatable {
    public let totalThisMonth: Decimal
    public let jobsCount: Int
}

public struct JobEarning: Identifiable, Equatable {
    public let id: UUID
    public let serviceName: String
    public let patientName: String
    public let dateText: String
    public let amount: Decimal
    public let status: JobEarningStatus
    public let iconName: String
}

public struct PayoutSummary: Equatable {
    public let availableForPayout: Decimal
    public let pending: Decimal
    public let thisMonth: Decimal
}

public struct PayoutTransaction: Identifiable, Equatable {
    public let id: UUID
    public let methodType: PayoutMethodType
    public let dateText: String
    public let amount: Decimal
    public let status: PayoutTransactionStatus
}