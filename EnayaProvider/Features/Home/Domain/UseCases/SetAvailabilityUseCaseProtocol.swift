//
//  SetAvailabilityUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


protocol SetAvailabilityUseCaseProtocol {
    func execute(_ status: ProviderAvailability) async throws
}

struct SetAvailabilityUseCase: SetAvailabilityUseCaseProtocol {
    private let repository: HomeRepositoryProtocol

    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ status: ProviderAvailability) async throws {
        try await repository.setAvailability(status)
    }
}