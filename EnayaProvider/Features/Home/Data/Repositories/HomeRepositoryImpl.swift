//
//  HomeRepositoryImpl.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//

import Foundation

final class HomeRepositoryImpl: HomeRepositoryProtocol {
    private let networkClient: NetworkClientProtocol
    private var hubService: NurseHomeHubServiceProtocol
    private let locationService: CurrentLocationServiceProtocol
    private let tokenStore: TokenStoring

    private var heartbeatTask: Task<Void, Never>?
    private let availabilityKey = "providerAvailability"

    private var activeRequests: [JobRequest] = []
    private var requestsContinuation: AsyncStream<[JobRequest]>.Continuation?

    init(
        networkClient: NetworkClientProtocol,
        hubService: NurseHomeHubServiceProtocol,
        locationService: CurrentLocationServiceProtocol,
        tokenStore: TokenStoring
    ) {
        self.networkClient = networkClient
        self.hubService = hubService
        self.locationService = locationService
        self.tokenStore = tokenStore
    }

    func fetchSummary() async throws -> ProviderHomeSummary {
        guard let nurseId = tokenStore.getNurseId() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Nurse ID not found"])
        }

        let nurseInfo: NurseInfoDTO = try await networkClient.request(HomeEndpoint.getNurseInfo(nurseId: nurseId))

        return ProviderHomeSummary(
            providerName: "\(nurseInfo.firstName) \(nurseInfo.lastName)".trimmingCharacters(in: .whitespaces),
            profileImageUrl: nurseInfo.profileImageUrl,
            todaysEarnings: 0.0,
            earningsChangePercent: 0,
            todaysJobsCount: 0,
            rating: nurseInfo.ratingAvg
        )
    }

    func setAvailability(isOnline: Bool) async throws {
        var lat = 0.0
        var lng = 0.0

        if isOnline {
            let location = try await locationService.getCurrentLocation()
            lat = location.latitude
            lng = location.longitude
            
            hubService.connect()
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
        } else {
            stopHeartbeat()
        }

        UserDefaults.standard.set(isOnline ? "online" : "offline", forKey: availabilityKey)
        
        hubService.updateAvailability(isAvailable: isOnline, lat: lat, lng: lng)

        if isOnline {
            startHeartbeat()
        }
    }

    private func startHeartbeat() {
        heartbeatTask?.cancel()
        heartbeatTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.hubService.sendHeartbeat()
                try? await Task.sleep(nanoseconds: 30_000_000_000)
            }
        }
    }

    private func stopHeartbeat() {
        heartbeatTask?.cancel()
        heartbeatTask = nil
    }

    func observeJobRequests() -> AsyncStream<[JobRequest]> {
        AsyncStream { continuation in
            self.requestsContinuation = continuation
            hubService.connect()

            Task {
                try? await self.fetchAndIngestHistoricalRequests()
            }

            hubService.onNearbyRequestReceived = { [weak self] response in
                guard let self = self else { return }
                Task { await self.ingestNearbyRequest(response) }
            }

            continuation.onTermination = { [weak self] _ in
                self?.hubService.unsubscribeFromNearbyRequests()
                self?.requestsContinuation = nil
                self?.activeRequests.removeAll()
            }
        }
    }

    func refreshJobRequests() async throws -> [JobRequest] {
        try await fetchAndIngestHistoricalRequests(pruneMissing: true)
    }

    @MainActor
    @discardableResult
    private func fetchAndIngestHistoricalRequests(pruneMissing: Bool = false) async throws -> [JobRequest] {
        try? await Task.sleep(nanoseconds: 500_000_000)
        let historicalRequests: [NearbyNurseServiceRequestResponse] = try await networkClient.request(HomeEndpoint.getNearbyServiceRequests)

        if pruneMissing {
            let currentIds = Set(historicalRequests.compactMap { UUID(uuidString: $0.serviceRequestId) })
            activeRequests.removeAll { !currentIds.contains($0.id) }
            requestsContinuation?.yield(activeRequests)
        }

        for response in historicalRequests {
            await ingestNearbyRequest(response)
        }

        return activeRequests
    }

    @MainActor
    private func ingestNearbyRequest(_ response: NearbyNurseServiceRequestResponse) async {
        let requestId = UUID(uuidString: response.serviceRequestId) ?? UUID()
        
        do {
            let preview = try await fetchServiceRequestPreview(serviceRequestId: response.serviceRequestId)
            let basePrice = Decimal(preview.estimatedPrice ?? response.estimatedPrice ?? 100)
            
            let minPrice = basePrice * 0.8
            let maxPrice = basePrice * 1.5

            let patientName: String
            if let fName = preview.patient?.firstName, let lName = preview.patient?.lastName {
                patientName = "\(fName) \(lName)".trimmingCharacters(in: .whitespaces)
            } else {
                patientName = "Patient #\(response.profileId.prefix(4))"
            }

            let jobRequest = JobRequest(
                id: requestId,
                patientLabel: patientName,
                patientImageUrl: preview.patient?.profileImageUrl ?? "",
                distanceText: String(format: "%.1f km", response.distanceKm),
                serviceName: response.serviceName,
                estimatedPrice: basePrice,
                minPrice: minPrice,
                maxPrice: maxPrice,
                proposedPrice: basePrice,
                status: .pending
            )

            if let index = activeRequests.firstIndex(where: { $0.id == requestId }) {
                activeRequests[index] = jobRequest
            } else {
                activeRequests.insert(jobRequest, at: 0)
            }
            requestsContinuation?.yield(activeRequests)
            
        } catch {
            let basePrice = Decimal(response.estimatedPrice ?? 100)
            let minPrice = basePrice * 0.8
            let maxPrice = basePrice * 1.5
            
            let jobRequest = JobRequest(
                id: requestId,
                patientLabel: "Patient #\(response.profileId.prefix(4))",
                patientImageUrl: "",
                distanceText: String(format: "%.1f km", response.distanceKm),
                serviceName: response.serviceName,
                estimatedPrice: basePrice,
                minPrice: minPrice,
                maxPrice: maxPrice,
                proposedPrice: basePrice,
                status: .pending
            )
            
            if let index = activeRequests.firstIndex(where: { $0.id == requestId }) {
                activeRequests[index] = jobRequest
            } else {
                activeRequests.insert(jobRequest, at: 0)
            }
            requestsContinuation?.yield(activeRequests)
        }
    }

    func fetchServiceRequestPreview(serviceRequestId: String) async throws -> ServiceRequestPreviewResponseDTO {
        try await networkClient.request(HomeEndpoint.getServiceRequestPreview(serviceRequestId: serviceRequestId))
    }

    func observeSocketErrors() -> AsyncStream<SocketErrorPayload> {
        AsyncStream { continuation in
            hubService.subscribeToErrors { errorPayload in
                continuation.yield(errorPayload)
            }
        }
    }

    func submitOffer(for request: JobRequest, proposedPrice: Decimal) async throws -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        let formattedRequestId = request.id.uuidString.lowercased()
        let formattedPrice = Double(truncating: NSDecimalNumber(decimal: proposedPrice))
        let roundedPrice = (formattedPrice * 100).rounded() / 100

        let requestDTO = NurseOfferRequestDTO(
            serviceRequestId: formattedRequestId,
            proposedPrice: roundedPrice,
            proposedDate: dateFormatter.string(from: date),
            proposedTime: timeFormatter.string(from: date),
            message: "I am available to assist you."
        )

        let response: NurseOfferResponseDTO = try await networkClient.request(HomeEndpoint.submitOffer(request: requestDTO))
        return response.id
    }

    func withdrawOffer(offerId: String) async throws {
        hubService.withdrawOffer(offerId: offerId)
    }

    func observeReservationEvents(reservationId: String) -> AsyncStream<ReservationEventResponse> {
        AsyncStream { continuation in
            hubService.subscribeToReservation(reservationId: reservationId) { event in
                continuation.yield(event)
            }
            continuation.onTermination = { [weak self] _ in
                self?.hubService.unsubscribeFromReservation(reservationId: reservationId)
            }
        }
    }

    func fetchCurrentActiveVisit() async throws -> ServiceRequestDetailsResponseDTO? {
        do {
            let response: ServiceRequestDetailsResponseDTO = try await networkClient.request(HomeEndpoint.getCurrentActiveVisit)
            return response
        } catch {
            return nil
        }
    }
}
