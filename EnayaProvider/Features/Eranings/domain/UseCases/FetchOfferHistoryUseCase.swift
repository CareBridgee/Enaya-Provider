//
//  FetchOfferHistoryUseCase.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 14/08/2026.
//
//  (file name kept for project-reference stability)
//

import Foundation

public struct FetchNurseHistoryUseCase {
    let repository: NurseHistoryRepositoryProtocol

    public init(repository: NurseHistoryRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [NurseServiceRequestHistoryItem] {
        try await repository.fetchHistory()
    }
}
