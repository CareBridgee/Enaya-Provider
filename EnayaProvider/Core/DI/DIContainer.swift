//
//  AppContainer.swift
//  Carely
//
//  Created by Mona Zarea on 15/07/2026.
//

// I will instantiate it once at the absolute highest pointz
import Foundation
import Alamofire
@MainActor
final class DIContainer {

    let appState: AppState
    
    private let tokenStore: TokenStoring
    private let sessionManager: SessionManager
    private let unauthNetworkClient: NetworkClientProtocol
    private let authInterceptor: AuthInterceptor
    
    init() {
        self.tokenStore = KeychainTokenStore()
        self.sessionManager = SessionManager(tokenStore: tokenStore)
        self.unauthNetworkClient = NetworkClient(session: .default)
        
        self.authInterceptor = AuthInterceptor(
            tokenStore: tokenStore,
            sessionMonitor: sessionManager,
            unauthNetworkClient: unauthNetworkClient
        )
        
        self.appState = AppState(sessionManager: sessionManager)
    }
    private lazy var session: Session = Session(interceptor: authInterceptor)
    
    private lazy var networkClient: NetworkClientProtocol = NetworkClient(session: session)

    private lazy var authService: AuthServiceProtocol = AuthServiceImpl(
        networkClient: networkClient
    )
    private lazy var authRepository: AuthRepositoryProtocol = AuthRepositoryImpl(
        authService: authService
    )
    
    private func makeLoginUseCase() -> LoginUseCaseProtocol {
        LoginUseCase(repository: authRepository)
    }
    
    private func makeVerifyOTPUseCase() -> VerifyOTPUseCaseProtocol {
        VerifyOTPUseCase(repository: authRepository, tokenStore: tokenStore, sessionManager: sessionManager)
    }

    func makeWelcomeViewModel(router: AuthRouter) -> WelcomeViewModel {
        WelcomeViewModel(router: router)
    }

    func makePhoneNumberViewModel(router: AuthRouter) -> PhoneNumberViewModel {
        PhoneNumberViewModel(
            loginUseCase: makeLoginUseCase(),
            router: router
        )
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
            onApproved: @escaping () -> Void,
            onBackToLogin: @escaping () -> Void
        ) -> UnderReviewViewModel {
            UnderReviewViewModel(onContactSupport: onContactSupport, onApproved: onApproved, onBackToLogin: onBackToLogin)
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
    // MARK: - Home

        private lazy var homeRepository: HomeRepositoryProtocol = HomeRepositoryImpl()

        private func makeFetchHomeSummaryUseCase() -> FetchHomeSummaryUseCaseProtocol {
            FetchHomeSummaryUseCase(repository: homeRepository)
        }

        private func makeFetchAvailabilityUseCase() -> FetchAvailabilityUseCaseProtocol {
            FetchAvailabilityUseCase(repository: homeRepository)
        }

        private func makeSetAvailabilityUseCase() -> SetAvailabilityUseCaseProtocol {
            SetAvailabilityUseCase(repository: homeRepository)
        }

        private func makeFetchActiveJobRequestUseCase() -> FetchActiveJobRequestUseCaseProtocol {
            FetchActiveJobRequestUseCase(repository: homeRepository)
        }

        private func makeConfirmJobRequestUseCase() -> ConfirmJobRequestUseCaseProtocol {
            ConfirmJobRequestUseCase(repository: homeRepository)
        }

        private func makeCancelJobRequestUseCase() -> CancelJobRequestUseCaseProtocol {
            CancelJobRequestUseCase(repository: homeRepository)
        }
    private func makeObserveJobRequestsUseCase() -> ObserveJobRequestsUseCaseProtocol {
            ObserveJobRequestsUseCase(repository: homeRepository)
        }
    func makeHomeViewModel() -> HomeViewModel {
            HomeViewModel(
                fetchSummaryUseCase: makeFetchHomeSummaryUseCase(),
                fetchAvailabilityUseCase: makeFetchAvailabilityUseCase(),
                setAvailabilityUseCase: makeSetAvailabilityUseCase(),
                observeJobRequestsUseCase: makeObserveJobRequestsUseCase(), 
                confirmJobRequestUseCase: makeConfirmJobRequestUseCase(),
                cancelJobRequestUseCase: makeCancelJobRequestUseCase()
            )
        }
    // MARK: - Offer

        private lazy var offerRepository: OfferRepositoryProtocol = OfferRepositoryImpl()

        private func makeStartVisitUseCase() -> StartVisitUseCaseProtocol {
            StartVisitUseCase(repository: offerRepository)
        }

        private func makeCompleteVisitUseCase() -> CompleteVisitUseCaseProtocol {
            CompleteVisitUseCase(repository: offerRepository)
        }

        private func makeCancelOfferUseCase() -> CancelOfferUseCaseProtocol {
            CancelOfferUseCase(repository: offerRepository)
        }

        func makeOfferCoordinator(offer: ConfirmedOffer) -> OfferCoordinator {
            OfferCoordinator(offer: offer)
        }

        func makeOfferConfirmedViewModel(coordinator: OfferCoordinator) -> OfferConfirmedViewModel {
            OfferConfirmedViewModel(
                coordinator: coordinator,
                startVisitUseCase: makeStartVisitUseCase(),
                completeVisitUseCase: makeCompleteVisitUseCase()
            )
        }

        func makeOfferDetailsViewModel(coordinator: OfferCoordinator) -> OfferDetailsViewModel {
            OfferDetailsViewModel(coordinator: coordinator)
        }

        func makeVisitCompletedViewModel(coordinator: OfferCoordinator, onReturnHome: @escaping () -> Void) -> VisitCompletedViewModel {
            VisitCompletedViewModel(coordinator: coordinator, onReturnHome: onReturnHome)
        }

        func makeCancelOfferViewModel(coordinator: OfferCoordinator, onCancelled: @escaping () -> Void) -> CancelOfferViewModel {
            CancelOfferViewModel(
                coordinator: coordinator,
                cancelOfferUseCase: makeCancelOfferUseCase(),
                onCancelled: onCancelled
            )
        }
    // MARK: - Earnings

        private lazy var earningsRepository: EarningsRepositoryProtocol = EarningsRepositoryImpl()

        private func makeFetchEarningsDataUseCase() -> FetchEarningsDataUseCase {
            FetchEarningsDataUseCase(repository: earningsRepository)
        }

        func makeEarningsHistoryViewModel(coordinator: EarningsCoordinator) -> EarningsHistoryViewModel {
            EarningsHistoryViewModel(
                coordinator: coordinator,
                useCase: makeFetchEarningsDataUseCase()
            )
        }

        func makePayoutsViewModel(coordinator: EarningsCoordinator) -> PayoutsViewModel {
            PayoutsViewModel(
                coordinator: coordinator,
                useCase: makeFetchEarningsDataUseCase()
            )
        }
}
