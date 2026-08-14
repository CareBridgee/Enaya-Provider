//
//  OfferHistoryRepositoryImpl.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 14/08/2026.
//
//  (file name kept for project-reference stability)
//

import Foundation

public final class NurseHistoryRepositoryImpl: NurseHistoryRepositoryProtocol {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    public func fetchHistory() async throws -> [NurseServiceRequestHistoryItem] {
        let dtos: [NurseServiceRequestHistoryDTO] = try await networkClient.request(
            NurseHistoryEndpoint.getHistory
        )
        return dtos.map(NurseServiceRequestHistoryMapper.map)
    }
}
