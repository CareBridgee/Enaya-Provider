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
    @Published var errorMessage: String?
    @Published var confirmedOffer: ConfirmedOffer?
    
    private var activeOfferId: String?
    private var hubConnectionTask: Task<Void, Never>?
    
    private let fetchSummary: FetchHomeSummaryUseCase
    private let toggleAvailabilityUseCase: ToggleAvailabilityUseCase
    private let observeJobRequests: ObserveJobRequestsUseCase
    private let submitOfferUseCase: SubmitOfferUseCase
    private let cancelOfferUseCase: CancelJobRequestUseCase
    
    private let observeReservationEventsUseCase: ObserveReservationEventsUseCaseProtocol
        private var reservationTask: Task<Void, Never>?

    private let fetchServiceRequestProfileUseCase: FetchServiceRequestProfileUseCaseProtocol

        init(
            fetchSummary: FetchHomeSummaryUseCase,
            toggleAvailabilityUseCase: ToggleAvailabilityUseCase,
            observeJobRequests: ObserveJobRequestsUseCase,
            submitOfferUseCase: SubmitOfferUseCase,
            cancelOfferUseCase: CancelJobRequestUseCase,
            observeReservationEventsUseCase: ObserveReservationEventsUseCaseProtocol,
            fetchServiceRequestProfileUseCase: FetchServiceRequestProfileUseCaseProtocol
        ) {
            self.fetchSummary = fetchSummary
            self.toggleAvailabilityUseCase = toggleAvailabilityUseCase
            self.observeJobRequests = observeJobRequests
            self.submitOfferUseCase = submitOfferUseCase
            self.cancelOfferUseCase = cancelOfferUseCase
            self.observeReservationEventsUseCase = observeReservationEventsUseCase
            self.fetchServiceRequestProfileUseCase = fetchServiceRequestProfileUseCase
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
        errorMessage = nil
        do {
            summary = try await fetchSummary.execute()
            
            let rawStatus = UserDefaults.standard.string(forKey: "providerAvailability")
            availability = ProviderAvailability(rawValue: rawStatus ?? "") ?? .offline
            
            if availability == .online {
                do {
                    try await toggleAvailabilityUseCase.execute(isOnline: true)
                    startObservingRequests()
                    print("✅ [HomeVM] App launched while Online: Location refreshed and sent successfully.")
                } catch {
                    print("⚠️ [HomeVM] Failed to refresh location on launch: \(error)")
                    availability = .offline
                    UserDefaults.standard.set("offline", forKey: "providerAvailability")
                }
            }
        } catch {
            errorMessage = "Couldn't load dashboard data."
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
                errorMessage = "Cannot go online without location access. Please check permissions."
            }
            isLoading = false
        }
    }

    private func startObservingRequests() {
        hubConnectionTask?.cancel()
        hubConnectionTask = Task { @MainActor in
            for await requests in observeJobRequests.execute() {
                print("🔄 [HomeVM] UI is updating with \(requests.count) requests")
                withAnimation(.spring()) {
                    self.jobRequests = requests
                }
            }
        }
    }
    
    private func stopObservingRequests() {
        hubConnectionTask?.cancel()
        withAnimation { jobRequests.removeAll() }
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

            Task {
                do {
                    let offerId = try await submitOfferUseCase.execute(request: request, price: price)
                    self.activeOfferId = offerId
                    observeReservation(for: request)
                } catch let error {
                    withAnimation { isWaitingForPatient = false }
                    let nsError = error as NSError
                    if let serverMessage = nsError.userInfo[NSLocalizedDescriptionKey] as? String {
                        errorMessage = serverMessage
                    } else {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }

    private func observeReservation(for request: JobRequest) {
            reservationTask?.cancel()
            let reservationId = request.id.uuidString.lowercased()

            reservationTask = Task { @MainActor in
                for await event in observeReservationEventsUseCase.execute(reservationId: reservationId) {
                    switch event.type.uppercased() {
                    case "OFFER_ACCEPTED":
                        await handleOfferAccepted(request: request)
                        reservationTask?.cancel()
                        return
                    case "OFFER_REJECTED", "OFFER_WITHDRAWN":
                        withAnimation { isWaitingForPatient = false }
                        activeOfferId = nil
                        errorMessage = "The patient declined your offer."
                        reservationTask?.cancel()
                        return
                    default:
                        break
                    }
                }
            }
        }

        private func handleOfferAccepted(request: JobRequest) async {
            do {
                let profile = try await fetchServiceRequestProfileUseCase.execute(serviceRequestId: request.id.uuidString)
                withAnimation { isWaitingForPatient = false }
                activeOfferId = nil
                confirmedOffer = buildConfirmedOffer(from: profile, proposedPrice: request.proposedPrice)
            } catch {
                withAnimation { isWaitingForPatient = false }
                errorMessage = "Offer accepted, but couldn't load the visit details. Pull to refresh."
            }
        }

        private func buildConfirmedOffer(from profile: ServiceRequestProfileResponseDTO, proposedPrice: Decimal) -> ConfirmedOffer {
            let ageText = calculateAge(from: profile.patient.dateOfBirth)
            let timeText = formattedTime(profile.preferredTime)
            let dateText = formattedDate(profile.preferredDate)

            return ConfirmedOffer(
                id: UUID(uuidString: profile.serviceRequestId) ?? UUID(),
                patient: OfferPatient(name: "\(profile.patient.firstName) \(profile.patient.lastName)", ageText: ageText, phoneNumber: profile.patientPhoneNumber),
                serviceName: profile.serviceName,
                serviceIcon: "cross.case.fill",
                distanceText: "",
                estimatedArrivalText: timeText,
                scheduledDateText: dateText,
                scheduledTimeText: timeText,
                durationMinutes: 45,
                address: OfferAddress(
                    line: profile.address?.formattedLine ?? "",
                    detail: profile.address?.formattedDetail ?? "",
                    addressText: profile.address?.fullAddressText ?? ""
                ),
                totalAmount: proposedPrice,
                providerPayoutAmount: proposedPrice - (proposedPrice * 0.15),
                completedDateText: "",
                status: .confirmed
            )
        }

        private func calculateAge(from dateOfBirth: String?) -> String? {
            guard let dateOfBirth else { return nil }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            guard let dob = formatter.date(from: dateOfBirth) else { return nil }
            let age = Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 0
            return "\(age)"
        }

        private func formattedTime(_ time: PreferredTimeDTO?) -> String {
            guard let time else { return "Time TBD" }
            var components = DateComponents()
            components.hour = time.hour
            components.minute = time.minute
            guard let date = Calendar.current.date(from: components) else { return "Time TBD" }
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        }

        private func formattedDate(_ dateString: String?) -> String {
            guard let dateString else { return "Date TBD" }
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd"
            guard let date = inputFormatter.date(from: dateString) else { return dateString }
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM d"
            return outputFormatter.string(from: date)
        }

    func cancelWaitingOffer() {
            reservationTask?.cancel()
            reservationTask = nil

            guard let offerId = activeOfferId else {
                withAnimation { isWaitingForPatient = false }
                return
            }

            Task {
                isLoading = true
                do {
                    try await cancelOfferUseCase.execute(offerId: offerId)
                    self.activeOfferId = nil

                    if let editingId = editingJobRequest?.id,
                       let index = jobRequests.firstIndex(where: { $0.id == editingId }) {
                        jobRequests[index].status = .cancelled
                    } else if let firstIndex = jobRequests.indices.first {
                        jobRequests[firstIndex].status = .cancelled
                    }

                    withAnimation { isWaitingForPatient = false }
                } catch {
                    errorMessage = "Failed to cancel offer."
                }
                isLoading = false
            }
        }
}

extension HomeViewModel {
    var earningsText: String { "$" + String(format: "%.2f", summary?.todaysEarnings.doubleValue ?? 0) }
    var earningsChangeText: String { String(format: "%.0f%% from yesterday", summary?.earningsChangePercent ?? 0) }
    var jobsCountText: String { "\(summary?.todaysJobsCount ?? 0) Total" }
    var ratingText: String { String(format: "%.1f", summary?.rating ?? 0) }
}
