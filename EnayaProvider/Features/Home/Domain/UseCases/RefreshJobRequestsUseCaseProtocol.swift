//
//  RefreshJobRequestsUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 09/08/2026.
//


import Foundation

protocol RefreshJobRequestsUseCaseProtocol {
    func execute() async throws -> [JobRequest]
}

struct RefreshJobRequestsUseCase: RefreshJobRequestsUseCaseProtocol {
    private let repository: HomeRepositoryProtocol
    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }
    func execute() async throws -> [JobRequest] {
        try await repository.refreshJobRequests()
    }
}