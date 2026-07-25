//
//  ObserveJobRequestsUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import Foundation

protocol ObserveJobRequestsUseCaseProtocol {
    func execute() -> AsyncStream<[JobRequest]>
}

struct ObserveJobRequestsUseCase: ObserveJobRequestsUseCaseProtocol {
    private let repository: HomeRepositoryProtocol

    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> AsyncStream<[JobRequest]> {
        repository.observeJobRequests()
    }
}