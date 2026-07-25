//
//  FetchHomeSummaryUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


protocol FetchHomeSummaryUseCaseProtocol {
    func execute() async throws -> ProviderHomeSummary
}

struct FetchHomeSummaryUseCase: FetchHomeSummaryUseCaseProtocol {
    private let repository: HomeRepositoryProtocol

    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> ProviderHomeSummary {
        try await repository.fetchSummary()
    }
}