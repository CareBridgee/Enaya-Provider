//
//  FetchServiceTypesUseCase.swift
//  EnayaProvider
//
//  Created by Mohamed Ayman on 05/08/2026.
//

import Foundation

protocol FetchServiceTypesUseCaseProtocol {
    func execute() async throws -> [CareService]
}

struct FetchServiceTypesUseCase: FetchServiceTypesUseCaseProtocol {
    private let repository: ProfileSetupRepositoryProtocol

    init(repository: ProfileSetupRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [CareService] {
        return try await repository.getServiceTypes()
    }
}
