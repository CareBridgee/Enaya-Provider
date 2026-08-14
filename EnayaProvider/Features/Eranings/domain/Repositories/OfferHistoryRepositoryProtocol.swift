//
//  OfferHistoryRepositoryProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 14/08/2026.
//
//  (file name kept for project-reference stability)
//

import Foundation

public protocol NurseHistoryRepositoryProtocol {
    /// Fetches the nurse's full service-request history,
    /// backed by GET /api/v1/service-requests/nurse/history
    func fetchHistory() async throws -> [NurseServiceRequestHistoryItem]
}
