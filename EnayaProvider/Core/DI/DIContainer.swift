//
//  AppContainer.swift
//  Carely
//
//  Created by Mona Zarea on 15/07/2026.
//

// I will instantiate it once at the absolute highest pointz
import Foundation

@MainActor
final class DIContainer {

    private lazy var authRepository: AuthRepositoryProtocol = {
        AuthRepositoryImpl()
    }()

    private func makeVerifyOTPUseCase() -> VerifyOTPUseCaseProtocol {
        VerifyOTPUseCase(repository: authRepository)
    }

    func makeWelcomeViewModel(router: AuthRouter) -> WelcomeViewModel {
        WelcomeViewModel(router: router)
    }

    func makePhoneNumberViewModel(router: AuthRouter) -> PhoneNumberViewModel {
        PhoneNumberViewModel(router: router)
    }

    func makeOTPVerificationViewModel(
        phoneNumber: String,
        router: AuthRouter,
        onAuthFinished: @escaping (ApplicationStatus) -> Void
    ) -> OTPVerificationViewModel {
        OTPVerificationViewModel(
            phoneNumber: phoneNumber,
            verifyOTPUseCase: makeVerifyOTPUseCase(),
            router: router,
            onAuthFinished: onAuthFinished
        )
    }

    // MARK: - ProfileSetup

    private lazy var profileSetupRepository: ProfileSetupRepositoryProtocol = ProfileSetupRepositoryImpl()

        private func makeSubmitProfileApplicationUseCase() -> SubmitProfileApplicationUseCaseProtocol {
            SubmitProfileApplicationUseCase(repository: profileSetupRepository)
        }

        func makeProfileSetupCoordinator() -> ProfileSetupCoordinator {
            ProfileSetupCoordinator(data: ProfileSetupData())
        }

        func makePersonalInfoViewModel(coordinator: ProfileSetupCoordinator) -> PersonalInfoViewModel {
            PersonalInfoViewModel(coordinator: coordinator)
        }

        func makeProfessionalInfoViewModel(coordinator: ProfileSetupCoordinator) -> ProfessionalInfoViewModel {
            ProfessionalInfoViewModel(coordinator: coordinator)
        }

        func makeProvidedServicesViewModel(coordinator: ProfileSetupCoordinator) -> ProvidedServicesViewModel {
            ProvidedServicesViewModel(coordinator: coordinator)
        }

        func makeReviewApplicationViewModel(
            coordinator: ProfileSetupCoordinator,
            onSubmitted: @escaping () -> Void
        ) -> ReviewApplicationViewModel {
            ReviewApplicationViewModel(
                coordinator: coordinator,
                submitApplicationUseCase: makeSubmitProfileApplicationUseCase(),
                onSubmitted: onSubmitted
            )
        }
    func makeUnderReviewViewModel(
            onContactSupport: @escaping () -> Void = {},
            onBackToLogin: @escaping () -> Void
        ) -> UnderReviewViewModel {
            UnderReviewViewModel(onContactSupport: onContactSupport, onBackToLogin: onBackToLogin)
        }

        func makeAccountVerifiedViewModel(onStartJourney: @escaping () -> Void) -> AccountVerifiedViewModel {
            AccountVerifiedViewModel(onStartJourney: onStartJourney)
        }

        func makeDocumentRejectedViewModel(onUploadAgain: @escaping () -> Void) -> DocumentRejectedViewModel {
            DocumentRejectedViewModel(
                rejection: DocumentRejection(
                    documentName: "Nursing License",
                    reason: "the photo was blurry",
                    tips: [
                        RejectionTip(icon: "sun.max.fill", title: "Ensure Good Lighting", detail: "Capture your document in a well-lit area without glare or shadows."),
                        RejectionTip(icon: "camera.viewfinder", title: "Stay in Focus", detail: "Hold your phone steady and make sure all text is sharp and legible."),
                        RejectionTip(icon: "crop", title: "Visible Edges", detail: "Place the document on a flat surface and show all four corners of the card.")
                    ]
                ),
                onUploadAgain: onUploadAgain
            )
        }
}
