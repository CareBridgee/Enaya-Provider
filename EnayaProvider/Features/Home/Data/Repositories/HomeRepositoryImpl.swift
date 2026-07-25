//
//  HomeRepositoryImpl.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import Foundation

final class HomeRepositoryImpl: HomeRepositoryProtocol {
    private let simulatedDelayNanoseconds: UInt64 = 900_000_000
    private static let availabilityKey = "providerAvailability"

    private var activeJobRequest: JobRequest? = .mock()

    func fetchSummary() async throws -> ProviderHomeSummary {
        try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        return ProviderHomeSummary(
            providerName: "mahmoud raafat",
            todaysEarnings: 240.00,
            earningsChangePercent: 12,
            todaysJobsCount: 3,
            rating: 4.9
        )
    }

    func fetchAvailability() async throws -> ProviderAvailability {
        try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        guard
            let rawStatus = UserDefaults.standard.string(forKey: Self.availabilityKey),
            let status = ProviderAvailability(rawValue: rawStatus)
        else {
            return .offline
        }
        return status
    }

    func setAvailability(_ status: ProviderAvailability) async throws {
        try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        UserDefaults.standard.set(status.rawValue, forKey: Self.availabilityKey)
    }

    func fetchActiveJobRequest() async throws -> JobRequest? {
        try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        return activeJobRequest
    }

    func confirmJobRequest(id: UUID, proposedPrice: Decimal) async throws -> JobRequest {
        try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        guard var request = activeJobRequest, request.id == id else {
            throw HomeError.requestNotFound
        }
        request.proposedPrice = proposedPrice
        request.status = .pending
        activeJobRequest = request
        return request
    }

    func cancelJobRequest(id: UUID) async throws {
        try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        guard activeJobRequest?.id == id else { return }
        activeJobRequest = nil
    }
    func observeJobRequests() -> AsyncStream<[JobRequest]> {
            AsyncStream { continuation in
                Task {
                    var activeRequests: [JobRequest] = []
                    
                    // 1. Initial state: Empty
                    continuation.yield(activeRequests)
                    
                    // 2. First request arrives
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    guard !Task.isCancelled else { return }
                    let request1 = JobRequest.mock1()
                    activeRequests.insert(request1, at: 0)
                    continuation.yield(activeRequests)
                    
                    // 3. Second request arrives 3 seconds later
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    guard !Task.isCancelled else { return }
                    let request2 = JobRequest.mock2()
                    activeRequests.insert(request2, at: 0)
                    continuation.yield(activeRequests)
                    
                    // 4. Patient cancels the first request a few seconds later
                    try? await Task.sleep(nanoseconds: 4_000_000_000)
                    guard !Task.isCancelled else { return }
                    activeRequests.removeAll { $0.id == request1.id }
                    continuation.yield(activeRequests)
                    
                    // The stream stays open until the ViewModel cancels the Task (e.g., going offline)
                }
            }
        }
}
