//
//  CancelJobRequestUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import Foundation

protocol CancelJobRequestUseCaseProtocol {
    func execute(id: UUID) async throws
}

struct CancelJobRequestUseCase: CancelJobRequestUseCaseProtocol {
    private let repository: HomeRepositoryProtocol

    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: UUID) async throws {
        try await repository.cancelJobRequest(id: id)
    }
}