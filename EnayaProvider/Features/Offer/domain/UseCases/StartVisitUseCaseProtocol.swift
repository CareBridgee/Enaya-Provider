//
//  StartVisitUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation

protocol StartVisitUseCaseProtocol {
    func execute(requestId: String) async throws
}

struct StartVisitUseCase: StartVisitUseCaseProtocol {
    let repository: OfferRepositoryProtocol
    
    func execute(requestId: String) async throws {
        try await repository.startVisit(requestId: requestId)
    }
}

protocol CompleteVisitUseCaseProtocol {
    func execute(requestId: String, visitCode: String) async throws
}

struct CompleteVisitUseCase: CompleteVisitUseCaseProtocol {
    let repository: OfferRepositoryProtocol
    
    func execute(requestId: String, visitCode: String) async throws {
        try await repository.completeVisit(requestId: requestId, visitCode: visitCode)
    }
}

