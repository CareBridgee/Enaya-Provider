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
    
    let tokenStore: TokenStoring
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
    private lazy var sharedSocketClient: SocketClientProtocol = {
        guard let url = URL(string: NetworkConfiguration.socketURL) else {
            fatalError("Invalid socket URL")
        }

        let client = StompSocketClient(url: url, tokenStore: tokenStore)
        client.onSessionExpired = {
          
            NotificationCenter.default.post(name: NSNotification.Name("SessionExpired"), object: nil)
        }
        client.onTokenExpiredOrFailed = { [weak self] in
            guard let self = self else { return false }

            guard let refreshToken = self.tokenStore.getRefreshToken(), !refreshToken.isEmpty else {
                return false
            }

            do {
                let authResponse = try await self.authService.refresh(refreshToken: refreshToken)

                self.tokenStore.saveTokens(
                    access: authResponse.accessToken,
                    refresh: authResponse.refreshToken
                )

                return true
            } catch {
                print("[Socket] Direct token refresh failed: \(error)")
                return false
            }
        }

        return client
    }()
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
    
    private lazy var cloudinaryService: CloudinaryUploadServiceProtocol = CloudinaryUploadService(session: .shared)
    private lazy var profileSetupService: ProfileSetupServiceProtocol = ProfileSetupServiceImpl(networkClient: networkClient)
    // MARK: - Notifications
        private lazy var notificationsHubService: NotificationsHubServiceProtocol = {
            return NotificationsSocketDataSource(socketClient: sharedSocketClient)
        }()
        
        func getNotificationsHubService() -> NotificationsHubServiceProtocol {
            return notificationsHubService
        }
    private lazy var profileSetupRepository: ProfileSetupRepositoryProtocol = ProfileSetupRepositoryImpl(
        profileService: profileSetupService,
        cloudinaryService: cloudinaryService
    )

    private func makeFetchServiceTypesUseCase() -> FetchServiceTypesUseCaseProtocol {
        FetchServiceTypesUseCase(repository: profileSetupRepository)
    }

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
            ProvidedServicesViewModel(
                coordinator: coordinator,
                fetchServiceTypesUseCase: makeFetchServiceTypesUseCase()
            )
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

        func makeAccountVerifiedViewModel(onStartJourney: @escaping () -> Void) -> AccountVerifiedViewModel {
            AccountVerifiedViewModel(onStartJourney: onStartJourney)
        }
        
    // MARK: - Nurse Verification Review (Post-Login)
        
    private lazy var nurseService: NurseServiceProtocol = NurseServiceImpl(networkClient: networkClient)
    private lazy var nurseRepository: NurseRepositoryProtocol = NurseRepositoryImpl(nurseService: nurseService)
    
    func makeGetNurseUseCase() -> GetNurseUseCaseProtocol {
        GetNurseUseCase(repository: nurseRepository)
    }
    
    func makeLogoutUseCase() -> LogoutUseCaseProtocol {
        LogoutUseCase(
            repository: authRepository,
            tokenStore: tokenStore,
            sessionManager: sessionManager
        )
    }
    
    func makeVerificationReviewViewModel(
        nurseId: String,
        verificationStatus: ApplicationStatus,
        onApproved: @escaping () -> Void,
        onLogout: @escaping () -> Void,
        onResubmit: @escaping () -> Void
    ) -> VerificationReviewViewModel {
        let initialNurse = NurseEntity(
            id: nurseId,
            firstName: nil,
            lastName: nil,
            verificationStatus: verificationStatus,
            rejectionReason: nil,
            rejectionDetails: nil
        )
        return VerificationReviewViewModel(
            nurse: initialNurse,
            nurseId: nurseId,
            getNurseUseCase: makeGetNurseUseCase(),
            logoutUseCase: makeLogoutUseCase(),
            onApproved: onApproved,
            onLogout: onLogout,
            onResubmit: onResubmit
        )
    }

    // MARK: - Home

    // MARK: - Location Service
        private lazy var currentLocationService: CurrentLocationServiceProtocol = {
            return CurrentLocationService()
        }()

        // MARK: - Hub Services
        private lazy var nurseHomeHubService: NurseHomeHubServiceProtocol = {
            return NurseHomeSocketDataSource(socketClient: sharedSocketClient)
        }()
        
        // MARK: - Repository
        private lazy var homeRepository: HomeRepositoryProtocol = {
            return HomeRepositoryImpl(
                networkClient: networkClient,
                hubService: nurseHomeHubService,
                locationService: currentLocationService,
                tokenStore: tokenStore
            )
        }()

        // MARK: - Use Cases
        private func makeFetchHomeSummaryUseCase() -> FetchHomeSummaryUseCase {
            FetchHomeSummaryUseCase(repository: homeRepository)
        }

        private func makeToggleAvailabilityUseCase() -> ToggleAvailabilityUseCase {
            ToggleAvailabilityUseCase(repo: homeRepository)
        }

        private func makeObserveJobRequestsUseCase() -> ObserveJobRequestsUseCase {
            ObserveJobRequestsUseCase(repository: homeRepository)
        }

        private func makeSubmitOfferUseCase() -> SubmitOfferUseCase {
            SubmitOfferUseCase(repo: homeRepository)
        }

    // MARK: - Home Feature
        
        private func makeCancelWaitingOfferUseCase() -> CancelJobRequestUseCase {
            CancelJobRequestUseCase(repo: homeRepository)
        }

    private func makeRefreshJobRequestsUseCase() -> RefreshJobRequestsUseCaseProtocol {
        RefreshJobRequestsUseCase(repository: homeRepository)
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            fetchSummary: makeFetchHomeSummaryUseCase(),
            toggleAvailabilityUseCase: makeToggleAvailabilityUseCase(),
            observeJobRequests: makeObserveJobRequestsUseCase(),
            refreshJobRequestsUseCase: makeRefreshJobRequestsUseCase(),
            submitOfferUseCase: makeSubmitOfferUseCase(),
            cancelOfferUseCase: makeCancelWaitingOfferUseCase(),
            observeReservationEventsUseCase: makeObserveReservationEventsUseCase()
        )
    }

        
        private lazy var offerRepository: OfferRepositoryProtocol = OfferRepositoryImpl(
            networkClient: networkClient
        )

        func makeFetchServiceRequestDetailsUseCase() -> FetchServiceRequestDetailsUseCase {
            FetchServiceRequestDetailsUseCase(repo: offerRepository)
        }
    func makeFetchServiceRequestProfileUseCase() -> FetchServiceRequestProfileUseCase {
        FetchServiceRequestProfileUseCase(repository: offerRepository)
    }

        func makeCancelServiceRequestUseCase() -> CancelServiceRequestUseCase {
            CancelServiceRequestUseCase(repo: offerRepository)
        }

        private func makeStartVisitUseCase() -> StartVisitUseCaseProtocol {
            StartVisitUseCase(repository: offerRepository)
        }

        private func makeCompleteVisitUseCase() -> CompleteVisitUseCaseProtocol {
            CompleteVisitUseCase(repository: offerRepository)
        }

        func makeOfferCoordinator(reservationId: String) -> OfferCoordinator {
            OfferCoordinator(reservationId: reservationId)
        }

        func makeOfferConfirmedViewModel(coordinator: OfferCoordinator) -> OfferConfirmedViewModel {
            OfferConfirmedViewModel(
                reservationId: coordinator.reservationId,
                coordinator: coordinator,
                fetchDetailsUseCase: makeFetchServiceRequestDetailsUseCase(),
                fetchProfileUseCase: makeFetchServiceRequestProfileUseCase(),
                completeVisitUseCase: makeCompleteVisitUseCase()
            )
        }

        func makeOfferDetailsViewModel(reservationId: String, coordinator: OfferCoordinator) -> OfferDetailsViewModel {
            OfferDetailsViewModel(
                reservationId: reservationId,
                coordinator: coordinator,
                fetchDetailsUseCase: makeFetchServiceRequestDetailsUseCase(),
                fetchProfileUseCase: makeFetchServiceRequestProfileUseCase()
            )
        }

        func makeCancelOfferViewModel(reservationId: String, serviceName: String, coordinator: OfferCoordinator, onCancelled: @escaping () -> Void) -> CancelOfferViewModel {
            CancelOfferViewModel(
                reservationId: reservationId,
                serviceName: serviceName,
                coordinator: coordinator,
                cancelRequestUseCase: makeCancelServiceRequestUseCase(),
                onCancelled: onCancelled
            )
        }

    func makeVisitCompletedViewModel(coordinator: OfferCoordinator, onReturnHome: @escaping () -> Void) -> VisitCompletedViewModel {
            VisitCompletedViewModel(
                reservationId: coordinator.reservationId,
                coordinator: coordinator,
                fetchDetailsUseCase: makeFetchServiceRequestDetailsUseCase(),
                onReturnHome: onReturnHome
            )
        }
    private func makeObserveReservationEventsUseCase() -> ObserveReservationEventsUseCaseProtocol {
         ObserveReservationEventsUseCase(repository: homeRepository)
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
