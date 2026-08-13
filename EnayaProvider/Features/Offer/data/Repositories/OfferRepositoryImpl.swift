//
//  OfferRepositoryImpl.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation



final class OfferRepositoryImpl: OfferRepositoryProtocol {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    func fetchRequestDetails(requestId: String) async throws -> ServiceRequestDetailsResponseDTO {
        return try await networkClient.request(OfferEndpoint.getRequestDetails(serviceRequestId: requestId))
    }
    
    func cancelServiceRequest(requestId: String) async throws {
        try await networkClient.requestWithoutResponse(OfferEndpoint.cancelServiceRequest(serviceRequestId: requestId))
    }
    
    func startVisit(requestId: String) async throws {
        try await networkClient.requestWithoutResponse(OfferEndpoint.startVisit(serviceRequestId: requestId))
    }
    
    func completeVisit(requestId: String, visitCode: String) async throws {
        try await networkClient.requestWithoutResponse(OfferEndpoint.completeVisit(serviceRequestId: requestId, visitCode: visitCode))
    }
    func fetchRequestProfile(requestId: String) async throws -> ServiceRequestProfileResponseDTO {
            return try await networkClient.request(OfferEndpoint.getServiceRequestProfile(serviceRequestId: requestId))
        }
}
