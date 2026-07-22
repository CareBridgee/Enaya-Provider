//
//  ReviewApplicationViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import Foundation

@MainActor
final class ReviewApplicationViewModel: ObservableObject {

    @Published private(set) var isSubmitting = false
    @Published var errorMessage: String?

    private let coordinator: ProfileSetupCoordinator
    private let submitApplicationUseCase: SubmitProfileApplicationUseCaseProtocol
    private let onSubmitted: () -> Void

    init(
        coordinator: ProfileSetupCoordinator,
        submitApplicationUseCase: SubmitProfileApplicationUseCaseProtocol,
        onSubmitted: @escaping () -> Void
    ) {
        self.coordinator = coordinator
        self.submitApplicationUseCase = submitApplicationUseCase
        self.onSubmitted = onSubmitted
    }

    var data: ProfileSetupData { coordinator.data }

    func backTapped() {
        coordinator.previous()
    }

    func editPersonalInfoTapped() { coordinator.go(to: .personalInfo) }
    func editProfessionalInfoTapped() { coordinator.go(to: .professionalInfo) }
    func editServicesTapped() { coordinator.go(to: .providedServices) }

    func submitTapped() {
        guard !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil

        Task {
            do {
                try await submitApplicationUseCase.execute(coordinator.data)
                isSubmitting = false
                onSubmitted()
            } catch {
                isSubmitting = false
                errorMessage = "Something went wrong submitting your application. Please try again."
            }
        }
    }
}