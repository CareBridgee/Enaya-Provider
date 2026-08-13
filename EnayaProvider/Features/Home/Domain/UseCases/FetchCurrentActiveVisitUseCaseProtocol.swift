//
//  FetchCurrentActiveVisitUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 12/08/2026.
//


import Foundation

protocol FetchCurrentActiveVisitUseCaseProtocol {
    func execute() async throws -> ServiceRequestDetailsResponseDTO?
}

struct FetchCurrentActiveVisitUseCase: FetchCurrentActiveVisitUseCaseProtocol {
    let repository: HomeRepositoryProtocol
    
    func execute() async throws -> ServiceRequestDetailsResponseDTO? {
        try await repository.fetchCurrentActiveVisit()
    }
}
