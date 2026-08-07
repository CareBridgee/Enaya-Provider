//
//  VerificationReviewViewModel.swift
//  EnayaProvider
//
//  Created by Mohamed Ayman on 05/08/2026.
//
import Foundation

enum VerificationReviewViewState: Equatable {
    case idle
    case refreshing
    case error(String)
}

@MainActor
final class VerificationReviewViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var nurse: NurseEntity
    @Published private(set) var state: VerificationReviewViewState = .idle

    // MARK: - Computed

    var isRefreshing: Bool { state == .refreshing }

    var errorMessage: String? {
        if case .error(let msg) = state { return msg }
        return nil
    }

    // MARK: - Private

    private let nurseId: String
    private let getNurseUseCase: GetNurseUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    private let onApproved: () -> Void
    private let onLogout: () -> Void
    private let onResubmit: () -> Void

    // MARK: - Init

    init(
        nurse: NurseEntity,
        nurseId: String,
        getNurseUseCase: GetNurseUseCaseProtocol,
        logoutUseCase: LogoutUseCaseProtocol,
        onApproved: @escaping () -> Void,
        onLogout: @escaping () -> Void,
        onResubmit: @escaping () -> Void
    ) {
        self.nurse          = nurse
        self.nurseId        = nurseId
        self.getNurseUseCase = getNurseUseCase
        self.logoutUseCase  = logoutUseCase
        self.onApproved     = onApproved
        self.onLogout       = onLogout
        self.onResubmit     = onResubmit
        Task {
            await refreshStatus()
        }
    }

    // MARK: - Actions

    func refreshStatus() async {
        guard state != .refreshing else { return }
        state = .refreshing

        do {
            let updated = try await getNurseUseCase.execute(nurseId: nurseId)
            nurse = updated
            state = .idle

            if updated.verificationStatus == .approved {
                onApproved()
            }
        } catch {
            state = .error("Unable to refresh status. Please try again.")
        }
    }

    func logoutTapped() async {
        do {
            try await logoutUseCase.execute()
            onLogout()
        } catch {
            // Logout failure is silent — tokens are always cleared locally
            onLogout()
        }
    }

    func resubmitTapped() {
        onResubmit()
    }
}
