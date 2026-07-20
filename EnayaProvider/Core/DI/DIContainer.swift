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
}
