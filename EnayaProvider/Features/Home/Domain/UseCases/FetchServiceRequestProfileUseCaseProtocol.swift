//
//  FetchServiceRequestProfileUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 07/08/2026.
//


protocol FetchServiceRequestProfileUseCaseProtocol {
    func execute(serviceRequestId: String) async throws -> ServiceRequestProfileResponseDTO
}

struct FetchServiceRequestProfileUseCase: FetchServiceRequestProfileUseCaseProtocol {
    let repository: HomeRepositoryProtocol
    func execute(serviceRequestId: String) async throws -> ServiceRequestProfileResponseDTO {
        try await repository.fetchServiceRequestProfile(serviceRequestId: serviceRequestId)
    }
}