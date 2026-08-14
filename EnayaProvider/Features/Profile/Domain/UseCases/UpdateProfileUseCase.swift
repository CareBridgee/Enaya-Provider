//
//  UpdateProfileUseCase.swift
//  EnayaProvider
//
//  Created by AI.
//

import Foundation

protocol UpdateProfileUseCaseProtocol {
    func execute(id: String, bio: String, specialization: String, yearsOfExperience: Int) async throws -> ProfileEntity
}

final class UpdateProfileUseCase: UpdateProfileUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String, bio: String, specialization: String, yearsOfExperience: Int) async throws -> ProfileEntity {
        return try await repository.updateProfile(id: id, bio: bio, specialization: specialization, yearsOfExperience: yearsOfExperience)
    }
}
