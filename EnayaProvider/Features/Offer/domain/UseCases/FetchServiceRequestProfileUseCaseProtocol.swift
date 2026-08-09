//
//  FetchServiceRequestProfileUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 09/08/2026.
//


import Foundation

protocol FetchServiceRequestProfileUseCaseProtocol {
    func execute(serviceRequestId: String) async throws -> ServiceRequestProfileResponseDTO
}

struct FetchServiceRequestProfileUseCase: FetchServiceRequestProfileUseCaseProtocol {
    let repository: OfferRepositoryProtocol
    
    func execute(serviceRequestId: String) async throws -> ServiceRequestProfileResponseDTO {
        return try await repository.fetchRequestProfile(requestId: serviceRequestId)
    }
}