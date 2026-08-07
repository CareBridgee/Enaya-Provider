//
//  GetNurseUseCase.swift
//  EnayaProvider
//
//  Created by Mohamed Ayman on 05/08/2026.
//

import Foundation

protocol GetNurseUseCaseProtocol {
    func execute(nurseId: String) async throws -> NurseEntity
}

struct GetNurseUseCase: GetNurseUseCaseProtocol {
    private let repository: NurseRepositoryProtocol

    init(repository: NurseRepositoryProtocol) {
        self.repository = repository
    }

    func execute(nurseId: String) async throws -> NurseEntity {
        return try await repository.getNurse(id: nurseId)
    }
}
