//
//  UpdateDocumentUseCase.swift
//  EnayaProvider
//
//  Created by AI.
//

import Foundation

protocol UpdateDocumentUseCaseProtocol: Sendable {
    func execute(id: String, type: DocumentUploadType, imageData: Data) async throws -> ProfileEntity
}

final class UpdateDocumentUseCase: UpdateDocumentUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String, type: DocumentUploadType, imageData: Data) async throws -> ProfileEntity {
        return try await repository.updateDocument(id: id, type: type, imageData: imageData)
    }
}
