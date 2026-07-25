//
//  UnderReviewViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import Foundation

@MainActor
final class UnderReviewViewModel: ObservableObject {
    private let onContactSupport: () -> Void
    private let onApproved: () -> Void
    private let onBackToLogin: () -> Void
    private let simulatedReviewDelayNanoseconds: UInt64 = 3_000_000_000

    init(
        onContactSupport: @escaping () -> Void = {},
        onApproved: @escaping () -> Void,
        onBackToLogin: @escaping () -> Void
    ) {
        self.onContactSupport = onContactSupport
        self.onApproved = onApproved
        self.onBackToLogin = onBackToLogin
        simulateReviewCompletion()
    }

    func contactSupportTapped() { onContactSupport() }
    func backToLoginTapped() { onBackToLogin() }

    private func simulateReviewCompletion() {
        Task {
            try? await Task.sleep(nanoseconds: simulatedReviewDelayNanoseconds)
            onApproved()
        }
    }
}
