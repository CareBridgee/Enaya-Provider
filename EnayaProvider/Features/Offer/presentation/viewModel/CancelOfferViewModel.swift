//
//  CancelOfferViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation

@MainActor
final class CancelOfferViewModel: ObservableObject {
    @Published var selectedReason: CancellationReason = .vehicleIssue
    @Published var detailText: String = ""
    @Published private(set) var isSubmitting = false
    @Published var errorMessage: String?

    private let coordinator: OfferCoordinator
    private let reservationId: String
    private let serviceName: String
    private let cancelRequestUseCase: CancelServiceRequestUseCase
    private let onCancelled: () -> Void

    init(reservationId: String, serviceName: String, coordinator: OfferCoordinator, cancelRequestUseCase: CancelServiceRequestUseCase, onCancelled: @escaping () -> Void) {
        self.reservationId = reservationId
        self.serviceName = serviceName
        self.coordinator = coordinator
        self.cancelRequestUseCase = cancelRequestUseCase
        self.onCancelled = onCancelled
    }

    var serviceNameDisplay: String { serviceName }
    
    var isConfirmEnabled: Bool {
        selectedReason != .other || !detailText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func dismissTapped() { coordinator.dismissCancelSheet() }

    func confirmTapped() {
        guard isConfirmEnabled, !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil
        
        coordinator.isNurseCancelling = true

        Task {
            do {
                try await cancelRequestUseCase.execute(requestId: reservationId)
                
                coordinator.markCancelled()
                isSubmitting = false
                
                coordinator.dismissCancelSheet()
                
                try? await Task.sleep(nanoseconds: 300_000_000)
                
                onCancelled()
            } catch {
                coordinator.isNurseCancelling = false
                isSubmitting = false
                errorMessage = error.localizedDescription
                print("Cancel Failed: \(error)")
            }
        }
    }
}


