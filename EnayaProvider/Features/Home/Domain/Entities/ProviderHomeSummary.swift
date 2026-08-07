//
//  ProviderHomeSummary.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import Foundation

struct ProviderHomeSummary: Equatable {
    let providerName: String
    let profileImageUrl:String?
    let todaysEarnings: Decimal
    let earningsChangePercent: Double
    let todaysJobsCount: Int
    let rating: Double
}
