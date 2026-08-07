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
    private var profileCache: [String: ServiceRequestProfileResponseDTO] = [:]

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
        let userMe: UserMeDTO = try await networkClient.request(HomeEndpoint.getUserMe)

        guard let nurseId = tokenStore.getNurseId() ?? userMe.defaultProfileId else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Nurse ID not found"])
        }

        let nurseInfo: NurseInfoDTO = try await networkClient.request(HomeEndpoint.getNurseInfo(nurseId: nurseId))

        return ProviderHomeSummary(
            providerName: "\(userMe.firstName) \(userMe.lastName)",
            profileImageUrl: userMe.profileImageUrl,
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
                    do {
                        let location = try await locationService.getCurrentLocation()
                        
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        
                        hubService.updateAvailability(isAvailable: true, lat: location.latitude, lng: location.longitude)
                        
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        
                        let historicalRequests: [NearbyNurseServiceRequestResponse] = try await networkClient.request(HomeEndpoint.getNearbyServiceRequests)
                        
                        for response in historicalRequests {
                            await self.ingestNearbyRequest(response)
                        }
                    } catch {
                        print("Failed to fetch historical nearby requests: \(error)")
                    }
                }
            hubService.onNearbyRequestReceived = { [weak self] response in
                guard let self = self else { return }
                Task { await self.ingestNearbyRequest(response) }
            }

            continuation.onTermination = { [weak self] _ in
                self?.hubService.unsubscribeFromNearbyRequests()
                self?.requestsContinuation = nil
                self?.activeRequests.removeAll()
                self?.profileCache.removeAll()
            }
        }
    }

    @MainActor
        private func ingestNearbyRequest(_ response: NearbyNurseServiceRequestResponse) async {
            let placeholder = JobRequest(
                id: UUID(uuidString: response.serviceRequestId) ?? UUID(),
                patientLabel: "Patient #\(response.profileId.prefix(4))",
                distanceText: String(format: "%.1f km", response.distanceKm),
                serviceName: response.serviceName,
                estimatedPrice: 0,
                minPrice: 0,
                maxPrice: 0,
                proposedPrice: 0,
                status: .pending
            )

            if !activeRequests.contains(where: { $0.id == placeholder.id }) {
                activeRequests.insert(placeholder, at: 0)
                requestsContinuation?.yield(activeRequests)
            }

            do {
                let preview = try await fetchServiceRequestPreview(serviceRequestId: response.serviceRequestId)
                let price = Decimal(preview.estimatedPrice ?? 0)

                if let index = activeRequests.firstIndex(where: { $0.id == placeholder.id }) {
                    if let fName = preview.patient?.firstName, let lName = preview.patient?.lastName {
                        activeRequests[index].patientLabel = "\(fName) \(lName)"
                    }
                    
                    activeRequests[index].estimatedPrice = price
                    activeRequests[index].minPrice = price
                    activeRequests[index].maxPrice = price
                    activeRequests[index].proposedPrice = price
                    requestsContinuation?.yield(activeRequests)
                }
            } catch {
                print("Failed to enrich service request preview \(response.serviceRequestId): \(error)")
            }
        }

        func fetchServiceRequestPreview(serviceRequestId: String) async throws -> ServiceRequestPreviewResponseDTO {
            return try await networkClient.request(HomeEndpoint.getServiceRequestPreview(serviceRequestId: serviceRequestId))
        }

        func fetchServiceRequestProfile(serviceRequestId: String) async throws -> ServiceRequestProfileResponseDTO {
            let key = serviceRequestId.lowercased()
            if let cached = profileCache[key] {
                return cached
            }
            let profile: ServiceRequestProfileResponseDTO = try await networkClient.request(HomeEndpoint.getServiceRequestProfile(serviceRequestId: serviceRequestId))
            profileCache[key] = profile
            return profile
        }

   

    func submitOffer(for request: JobRequest, proposedPrice: Decimal) async throws -> String {
        guard let nurseId = tokenStore.getNurseId() else { throw URLError(.userAuthenticationRequired) }

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        let offerRequest = NurseOfferRequestDTO(
            serviceRequestId: request.id.uuidString,
            nurseId: nurseId,
            proposedPrice: proposedPrice.doubleValue,
            proposedDate: dateFormatter.string(from: date),
            proposedTime: timeFormatter.string(from: date),
            message: "I am available to assist you."
        )

        let response: NurseOfferResponseDTO = try await networkClient.request(HomeEndpoint.submitOffer(request: offerRequest))
        return response.id
    }

    func cancelOffer(offerId: String) async throws {
        try await networkClient.requestWithoutResponse(HomeEndpoint.cancelOffer(offerId: offerId))
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
}
