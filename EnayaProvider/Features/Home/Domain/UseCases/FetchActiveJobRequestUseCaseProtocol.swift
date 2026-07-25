//
//  FetchActiveJobRequestUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


protocol FetchActiveJobRequestUseCaseProtocol {
    func execute() async throws -> JobRequest?
}

struct FetchActiveJobRequestUseCase: FetchActiveJobRequestUseCaseProtocol {
    private let repository: HomeRepositoryProtocol

    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> JobRequest? {
        try await repository.fetchActiveJobRequest()
    }
}