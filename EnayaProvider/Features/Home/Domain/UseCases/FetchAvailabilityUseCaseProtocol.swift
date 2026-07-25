//
//  FetchAvailabilityUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


protocol FetchAvailabilityUseCaseProtocol {
    func execute() async throws -> ProviderAvailability
}

struct FetchAvailabilityUseCase: FetchAvailabilityUseCaseProtocol {
    private let repository: HomeRepositoryProtocol

    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> ProviderAvailability {
        try await repository.fetchAvailability()
    }
}