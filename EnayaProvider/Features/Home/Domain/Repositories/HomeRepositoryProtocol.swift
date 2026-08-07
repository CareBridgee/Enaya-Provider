//
//  HomeRepositoryProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import Foundation

protocol HomeRepositoryProtocol {
    func fetchSummary() async throws -> ProviderHomeSummary
    func setAvailability(isOnline: Bool) async throws
    func observeJobRequests() -> AsyncStream<[JobRequest]>
    func submitOffer(for request: JobRequest, proposedPrice: Decimal) async throws -> String
    func cancelOffer(offerId: String) async throws
    func observeReservationEvents(reservationId: String) -> AsyncStream<ReservationEventResponse>
    func fetchServiceRequestPreview(serviceRequestId: String) async throws -> ServiceRequestPreviewResponseDTO 
    func fetchServiceRequestProfile(serviceRequestId: String) async throws -> ServiceRequestProfileResponseDTO
}
