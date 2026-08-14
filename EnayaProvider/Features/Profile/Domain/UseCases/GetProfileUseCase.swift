//
//  GetProfileUseCase.swift
//  EnayaProvider
//
//  Created by AI.
//

import Foundation

protocol GetProfileUseCaseProtocol {
    func execute(id: String) async throws -> ProfileEntity
}

struct GetProfileUseCase: GetProfileUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String) async throws -> ProfileEntity {
        return try await repository.getProfile(id: id)
    }
}
