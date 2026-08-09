//
//  OfferRepositoryProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation

protocol OfferRepositoryProtocol {
    func fetchRequestDetails(requestId: String) async throws -> ServiceRequestDetailsResponseDTO
    func cancelServiceRequest(requestId: String) async throws
    func startVisit(requestId: String) async throws
    func completeVisit(requestId: String, visitCode: String) async throws
    func fetchRequestProfile(requestId: String) async throws -> ServiceRequestProfileResponseDTO
}
