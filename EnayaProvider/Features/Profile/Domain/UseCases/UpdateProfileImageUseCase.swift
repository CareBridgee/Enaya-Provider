//
//  UpdateProfileImageUseCase.swift
//  EnayaProvider
//
//  Created by AI.
//

import Foundation

protocol UpdateProfileImageUseCaseProtocol {
    func execute(id: String, imageData: Data) async throws -> ProfileEntity
}

final class UpdateProfileImageUseCase: UpdateProfileImageUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String, imageData: Data) async throws -> ProfileEntity {
        return try await repository.updateProfileImage(id: id, imageData: imageData)
    }
}
