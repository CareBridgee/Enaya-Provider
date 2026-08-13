//
//  VisitCompletedViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation

@MainActor
final class VisitCompletedViewModel: ObservableObject {
    @Published var liveDetails: ServiceRequestDetailsResponseDTO?
    @Published var isLoading = true

    private let reservationId: String
    private let coordinator: OfferCoordinator
    private let fetchDetailsUseCase: FetchServiceRequestDetailsUseCase
    private let onReturnHome: () -> Void

    init(
        reservationId: String,
        coordinator: OfferCoordinator,
        fetchDetailsUseCase: FetchServiceRequestDetailsUseCase,
        onReturnHome: @escaping () -> Void
    ) {
        self.reservationId = reservationId
        self.coordinator = coordinator
        self.fetchDetailsUseCase = fetchDetailsUseCase
        self.onReturnHome = onReturnHome
    }

    func loadDetails() async {
        isLoading = true
        do {
            liveDetails = try await fetchDetailsUseCase.execute(requestId: reservationId)
            print("📸 [OfferConfirmedVM] Fetched Live Details | Patient Image URL: \(liveDetails?.profile.profileImageUrl ?? "nil")")
        } catch {
            print("Failed to load details: \(error)")
        }
        isLoading = false
    }

    // MARK: - View Data Properties
    
    var patientName: String {
        guard let p = liveDetails?.profile else { return "Loading..." }
        return "\(p.firstName ?? "") \(p.lastName ?? "")".trimmingCharacters(in: .whitespaces)
    }

    var serviceName: String {
        liveDetails?.serviceType.name ?? "Loading..."
    }

    var durationMinutes: Int {
        liveDetails?.durationMinutes ?? 0
    }

    var completedDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: Date()) // تاريخ اليوم لإكمال الزيارة
    }

    var providerPayoutAmount: Double {
        let proposedPrice = liveDetails?.offers?.first(where: { $0.status == "ACCEPTED" })?.proposedPrice ?? 0.0
        return proposedPrice - (proposedPrice * 0.15) // خصم 15% كما كان في الكود القديم
    }

    func returnHomeTapped() {
        onReturnHome()
    }
}
