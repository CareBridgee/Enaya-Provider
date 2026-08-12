import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {

    @Published private(set) var summary: ProviderHomeSummary?
    @Published private(set) var availability: ProviderAvailability = .offline
    @Published private(set) var jobRequests: [JobRequest] = []

    @Published var editingJobRequest: JobRequest?
    @Published var proposedPriceValue: Double = 0

    @Published private(set) var isWaitingForPatient: Bool = false
    @Published private(set) var isLoading = false
    @Published var showErrorAlert = false
    @Published var alertMessage = ""

    @Published var acceptedRequestId: String?

    private var activeOfferId: String?
    private var hubConnectionTask: Task<Void, Never>?
    private var reservationTask: Task<Void, Never>?
    private var waitingTimerTask: Task<Void, Never>?
    private var offerSubmissionTask: Task<Void, Never>?

    private let fetchSummary: FetchHomeSummaryUseCase
    private let toggleAvailabilityUseCase: ToggleAvailabilityUseCase
    private let observeJobRequests: ObserveJobRequestsUseCase
    private let refreshJobRequestsUseCase: RefreshJobRequestsUseCaseProtocol
    private let submitOfferUseCase: SubmitOfferUseCase
    private let withdrawOfferUseCase: WithdrawOfferUseCaseProtocol
    private let observeReservationEventsUseCase: ObserveReservationEventsUseCaseProtocol
    private let observeSocketErrorsUseCase: ObserveSocketErrorsUseCase
    
    private var errorObservationTask: Task<Void, Never>?

    init(
        fetchSummary: FetchHomeSummaryUseCase,
        toggleAvailabilityUseCase: ToggleAvailabilityUseCase,
        observeJobRequests: ObserveJobRequestsUseCase,
        refreshJobRequestsUseCase: RefreshJobRequestsUseCaseProtocol,
        submitOfferUseCase: SubmitOfferUseCase,
        withdrawOfferUseCase: WithdrawOfferUseCaseProtocol,
        observeSocketErrorsUseCase: ObserveSocketErrorsUseCase,
        observeReservationEventsUseCase: ObserveReservationEventsUseCaseProtocol
    ) {
        self.fetchSummary = fetchSummary
        self.toggleAvailabilityUseCase = toggleAvailabilityUseCase
        self.observeJobRequests = observeJobRequests
        self.refreshJobRequestsUseCase = refreshJobRequestsUseCase
        self.submitOfferUseCase = submitOfferUseCase
        self.withdrawOfferUseCase = withdrawOfferUseCase
        self.observeReservationEventsUseCase = observeReservationEventsUseCase
        self.observeSocketErrorsUseCase = observeSocketErrorsUseCase
    }

    var isOnline: Bool { availability == .online }

    var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    func load() async {
        isLoading = true
        do {
            summary = try await fetchSummary.execute()

            let rawStatus = UserDefaults.standard.string(forKey: "providerAvailability")
            availability = ProviderAvailability(rawValue: rawStatus ?? "") ?? .offline

            if availability == .online {
                do {
                    try await toggleAvailabilityUseCase.execute(isOnline: true)
                    startObservingRequests()
                } catch {
                    availability = .offline
                    UserDefaults.standard.set("offline", forKey: "providerAvailability")
                }
            }
        } catch {
            alertMessage = "Couldn't load dashboard data."
            showErrorAlert = true
        }
        isLoading = false
    }

    func toggleAvailability() {
        Task {
            isLoading = true
            let newStatus: ProviderAvailability = availability == .online ? .offline : .online

            do {
                try await toggleAvailabilityUseCase.execute(isOnline: newStatus == .online)

                availability = newStatus
                if newStatus == .online {
                    startObservingRequests()
                } else {
                    stopObservingRequests()
                }
            } catch {
                availability = .offline
                alertMessage = "Cannot go online without location access. Please check permissions."
                showErrorAlert = true
            }
            isLoading = false
        }
    }

    private func startObservingRequests() {
        hubConnectionTask?.cancel()
        hubConnectionTask = Task { @MainActor in
            for await requests in observeJobRequests.execute() {
                withAnimation(.spring()) {
                    self.jobRequests = requests
                }
            }
        }
        
        errorObservationTask?.cancel()
        errorObservationTask = Task { @MainActor in
            for await errorPayload in observeSocketErrorsUseCase.execute() {
                self.handleSocketError(errorPayload)
            }
        }
    }
    
    private func handleSocketError(_ error: SocketErrorPayload) {
        let msg = error.message ?? "An unexpected error occurred."
        
        if isWaitingForPatient {
            reservationTask?.cancel()
            waitingTimerTask?.cancel()
            withAnimation { isWaitingForPatient = false }
            
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                self.alertMessage = msg
                self.showErrorAlert = true
            }
        } else {
            alertMessage = msg
            showErrorAlert = true
        }
    }
      
    private func stopObservingRequests() {
        hubConnectionTask?.cancel()
        errorObservationTask?.cancel()
        withAnimation { jobRequests.removeAll() }
    }

    func refreshJobRequests() async {
        guard isOnline else { return }
        do {
            let updated = try await refreshJobRequestsUseCase.execute()
            withAnimation { jobRequests = updated }
        } catch {
        }
    }

    func handleOfferFlowFinished(reservationId: String) {
        acceptedRequestId = nil
        if let uuid = UUID(uuidString: reservationId) {
            withAnimation { jobRequests.removeAll { $0.id == uuid } }
        }
        Task { await refreshJobRequests() }
    }

    func startEditingOffer(for request: JobRequest) {
        proposedPriceValue = request.proposedPrice.doubleValue
        withAnimation { editingJobRequest = request }
    }

    func cancelEditing() {
        withAnimation { editingJobRequest = nil }
    }

    func saveEditedOffer() {
        guard var request = editingJobRequest else { return }
        request.proposedPrice = Decimal(proposedPriceValue)

        if let index = jobRequests.firstIndex(where: { $0.id == request.id }) {
            jobRequests[index] = request
        }

        cancelEditing()
    }

    func submitOffer(for request: JobRequest) {
        let price = Decimal(proposedPriceValue > 0 ? proposedPriceValue : request.proposedPrice.doubleValue)
        cancelEditing()

        withAnimation { isWaitingForPatient = true }
        activeOfferId = nil

        offerSubmissionTask = Task {
            do {
                let offerId = try await submitOfferUseCase.execute(request: request, price: price)
                
                guard !Task.isCancelled else { return }
                
                self.activeOfferId = offerId
                self.observeReservation(for: request)
                self.startWaitingTimer()
                
            } catch {
                guard !Task.isCancelled else { return }
                
                withAnimation { isWaitingForPatient = false }
                
                Task {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    self.alertMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    self.showErrorAlert = true
                }
            }
        }
    }

    private func startWaitingTimer() {
        waitingTimerTask?.cancel()
        waitingTimerTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            
            guard !Task.isCancelled, isWaitingForPatient else { return }
            
            self.alertMessage = "No response from the patient. Offer has been automatically deleted."
            self.showErrorAlert = true
            self.cancelWaitingOffer()
        }
    }

    private func observeReservation(for request: JobRequest) {
        reservationTask?.cancel()
        let reservationId = request.id.uuidString.lowercased()

        reservationTask = Task { @MainActor in
            for await event in observeReservationEventsUseCase.execute(reservationId: reservationId) {
                switch event.type.uppercased() {
                case "OFFER_ACCEPTED":
                    reservationTask?.cancel()
                    waitingTimerTask?.cancel()
                    withAnimation { isWaitingForPatient = false }
                    self.activeOfferId = nil
                    self.acceptedRequestId = reservationId
                    return

                case "OFFER_REJECTED", "OFFER_WITHDRAWN":
                    waitingTimerTask?.cancel()
                    withAnimation { isWaitingForPatient = false }
                    self.activeOfferId = nil
                    
                    Task {
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        self.alertMessage = "The patient declined your offer."
                        self.showErrorAlert = true
                    }
                    reservationTask?.cancel()
                    return

                case "REQUEST_CANCELLED":
                    waitingTimerTask?.cancel()
                    withAnimation { isWaitingForPatient = false }
                    self.activeOfferId = nil
                    
                    Task {
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        self.alertMessage = "The patient cancelled the request."
                        self.showErrorAlert = true
                    }
                    reservationTask?.cancel()
                    return

                default:
                    break
                }
            }
        }
    }

    func cancelWaitingOffer() {
        offerSubmissionTask?.cancel()
        reservationTask?.cancel()
        reservationTask = nil
        waitingTimerTask?.cancel()

        guard let offerId = activeOfferId else {
            withAnimation { isWaitingForPatient = false }
            Task { await refreshJobRequests() }
            return
        }
        
        withAnimation { isWaitingForPatient = false }

        Task {
            do {
                try await withdrawOfferUseCase.execute(offerId: offerId)
                self.activeOfferId = nil

                if let editingId = editingJobRequest?.id,
                   let index = jobRequests.firstIndex(where: { $0.id == editingId }) {
                    jobRequests[index].status = .cancelled
                } else if let firstIndex = jobRequests.indices.first {
                    jobRequests[firstIndex].status = .cancelled
                }
            } catch {
                self.alertMessage = "Failed to withdraw offer."
                self.showErrorAlert = true
            }
            await self.refreshJobRequests()
        }
    }
}

extension HomeViewModel {
    var earningsText: String { "$" + String(format: "%.2f", summary?.todaysEarnings.doubleValue ?? 0) }
    var earningsChangeText: String { String(format: "%.0f%% from yesterday", summary?.earningsChangePercent ?? 0) }
    var jobsCountText: String { "\(summary?.todaysJobsCount ?? 0) Total" }
    var ratingText: String { String(format: "%.1f", summary?.rating ?? 0) }
}
