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
                let userMe: UserMeDTO = try await networkClient.request(HomeEndpoint.getUserMe)
                guard let resolvedId = userMe.defaultProfileId ?? tokenStore.getNurseId() else {
                    throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Nurse ID not found"])
                }
                return try await fetchNurseSummary(nurseId: resolvedId)
            }
            
            return try await fetchNurseSummary(nurseId: nurseId)
        }

        private func fetchNurseSummary(nurseId: String) async throws -> ProviderHomeSummary {
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
                    
                    hubService.subscribeToErrors { errorPayload in
                        print("⚠️ [Socket Error Received]: \(errorPayload)")
                    }
                    
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
            }
        }
    }

    @MainActor
    private func ingestNearbyRequest(_ response: NearbyNurseServiceRequestResponse) async {
        let placeholder = JobRequest(
            id: UUID(uuidString: response.serviceRequestId) ?? UUID(),
            patientLabel: "Patient #\(response.profileId.prefix(4))",
            patientImageUrl: "",
            distanceText: String(format: "%.1f km", response.distanceKm),
            serviceName: response.serviceName,
            estimatedPrice: 100,
            minPrice: 100,
            maxPrice: 100,
            proposedPrice: 100,
            status: .pending
        )

        if !activeRequests.contains(where: { $0.id == placeholder.id }) {
            activeRequests.insert(placeholder, at: 0)
            requestsContinuation?.yield(activeRequests)
        }

        do {
            let preview = try await fetchServiceRequestPreview(serviceRequestId: response.serviceRequestId)
            print("📸 [HomeRepo] Fetched Preview for \(response.serviceRequestId) | Patient Image URL: \(preview.patient?.profileImageUrl ?? "nil")")
            let price = Decimal(preview.estimatedPrice ?? 100)

            if let index = activeRequests.firstIndex(where: { $0.id == placeholder.id }) {
                if let fName = preview.patient?.firstName, let lName = preview.patient?.lastName {
                    activeRequests[index].patientLabel = "\(fName) \(lName)"
                }
                
                activeRequests[index].patientImageUrl = preview.patient?.profileImageUrl ?? ""
                
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


    func submitOffer(for request: JobRequest, proposedPrice: Decimal) async throws {
        guard tokenStore.getNurseId() != nil else { throw URLError(.userAuthenticationRequired) }

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let formattedRequestId = request.id.uuidString.lowercased()

        let formattedPrice = Double(truncating: NSDecimalNumber(decimal: proposedPrice))
        let roundedPrice = (formattedPrice * 100).rounded() / 100

        hubService.sendOffer(
            serviceRequestId: formattedRequestId,
            price: roundedPrice,
            date: dateFormatter.string(from: date),
            time: timeFormatter.string(from: date),
            message: "I am available to assist you."
        )
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


   
