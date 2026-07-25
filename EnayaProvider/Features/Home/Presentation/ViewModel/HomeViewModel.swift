import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {

    @Published private(set) var summary: ProviderHomeSummary?
    @Published private(set) var availability: ProviderAvailability = .offline
    @Published private(set) var jobRequests: [JobRequest] = []
    
    @Published var editingJobRequest: JobRequest?
    @Published var proposedPriceValue: Double = 0
    
    // Waiting for Patient State
    @Published private(set) var isWaitingForPatient: Bool = false
    private var waitingTask: Task<Void, Never>?
    
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private var hubConnectionTask: Task<Void, Never>?

    private let fetchSummaryUseCase: FetchHomeSummaryUseCaseProtocol
    private let fetchAvailabilityUseCase: FetchAvailabilityUseCaseProtocol
    private let setAvailabilityUseCase: SetAvailabilityUseCaseProtocol
    private let observeJobRequestsUseCase: ObserveJobRequestsUseCaseProtocol
    private let confirmJobRequestUseCase: ConfirmJobRequestUseCaseProtocol
    private let cancelJobRequestUseCase: CancelJobRequestUseCaseProtocol

    init(
        fetchSummaryUseCase: FetchHomeSummaryUseCaseProtocol,
        fetchAvailabilityUseCase: FetchAvailabilityUseCaseProtocol,
        setAvailabilityUseCase: SetAvailabilityUseCaseProtocol,
        observeJobRequestsUseCase: ObserveJobRequestsUseCaseProtocol,
        confirmJobRequestUseCase: ConfirmJobRequestUseCaseProtocol,
        cancelJobRequestUseCase: CancelJobRequestUseCaseProtocol
    ) {
        self.fetchSummaryUseCase = fetchSummaryUseCase
        self.fetchAvailabilityUseCase = fetchAvailabilityUseCase
        self.setAvailabilityUseCase = setAvailabilityUseCase
        self.observeJobRequestsUseCase = observeJobRequestsUseCase
        self.confirmJobRequestUseCase = confirmJobRequestUseCase
        self.cancelJobRequestUseCase = cancelJobRequestUseCase
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
            async let summaryResult = fetchSummaryUseCase.execute()
            async let availabilityResult = fetchAvailabilityUseCase.execute()
            let (summary, availability) = try await (summaryResult, availabilityResult)
            self.summary = summary
            self.availability = availability
            
            if availability == .online {
                connectToHub()
            }
        } catch {
            errorMessage = "Couldn't load your dashboard. Pull to refresh."
        }
        isLoading = false
    }

    func toggleAvailability() {
            Task {
                let newStatus: ProviderAvailability = availability == .online ? .offline : .online
                do {
                    try await setAvailabilityUseCase.execute(newStatus)
                    availability = newStatus
                    
                    if newStatus == .online {
                        connectToHub()
                    } else {
                        disconnectFromHub()
                    }
                } catch {
                    errorMessage = "Couldn't update your status. Try again."
                }
            }
        }

        // MARK: - Hub Connection
        private func connectToHub() {
            hubConnectionTask?.cancel()
            hubConnectionTask = Task {
                for await requests in observeJobRequestsUseCase.execute() {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        self.jobRequests = requests
                    }
                }
            }
        }
        
        private func disconnectFromHub() {
            hubConnectionTask?.cancel()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                jobRequests.removeAll()
            }
        }

  

    func startEditingOffer(for request: JobRequest) {
        proposedPriceValue = request.proposedPrice.doubleValue
        withAnimation(.easeInOut(duration: 0.2)) {
            editingJobRequest = request
        }
    }

    func cancelEditing() {
        withAnimation(.easeInOut(duration: 0.2)) {
            editingJobRequest = nil
        }
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
            waitingTask?.cancel()
            
            withAnimation {
                isWaitingForPatient = true
            }
            
            waitingTask = Task {
                // Wait for 10 seconds for patient response
                try? await Task.sleep(nanoseconds: 10_000_000_000)
                
                // If the task was cancelled (user clicked cancel button), don't trigger timeout
                guard !Task.isCancelled else { return }
                
                withAnimation {
                    isWaitingForPatient = false
                    errorMessage = "Patient did not respond in time. The offer was cancelled."
                }
            }
        }

        func cancelWaitingOffer() {
            waitingTask?.cancel()
            withAnimation {
                isWaitingForPatient = false
            }
        }
    }
// MARK: - Display Formatting
extension HomeViewModel {
    var earningsText: String {
        "$" + String(format: "%.2f", summary?.todaysEarnings.doubleValue ?? 0)
    }

    var earningsChangeText: String {
        String(format: "%.0f%% from yesterday", summary?.earningsChangePercent ?? 0)
    }

    var jobsCountText: String {
        "\(summary?.todaysJobsCount ?? 0) Total"
    }

    var ratingText: String {
        String(format: "%.1f", summary?.rating ?? 0)
    }
}



