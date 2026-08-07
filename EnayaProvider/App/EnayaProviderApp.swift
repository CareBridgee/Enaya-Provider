//
//  EnayaProviderApp.swift
//  EnayaProvider
//
//  Created by Mona Zarea on 16/07/2026.
//
import SwiftUI

@main
struct EnayaProviderApp: App {

    let diContainer: DIContainer
    @StateObject private var appState: AppState

    @MainActor
    init() {
        let container = DIContainer()

        self.diContainer = container
        _appState = StateObject(wrappedValue: container.appState)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch appState.flow {
                case .auth:
                    AuthCoordinator(container: diContainer, appState: appState)

                case .profileSetup:
                    ProfileSetupCoordinatorView(
                        container: diContainer,
                        coordinator: diContainer.makeProfileSetupCoordinator(),
                        onFinish: { appState.completeAuth(with: .underReview) }
                    )

                case .underReview, .rejected:
                    if let rawStatus = AppSettings.shared.applicationStatus,
                       let status = ApplicationStatus(rawValue: rawStatus),
                       let nurseId = diContainer.tokenStore.getNurseId() {
                       
                        VerificationReviewView(
                            viewModel: diContainer.makeVerificationReviewViewModel(
                                nurseId: nurseId,
                                verificationStatus: status,
                                onApproved: { appState.completeAuth(with: .approved) },
                                onLogout: { appState.signOut() },
                                onResubmit: { appState.startProfileSetup() }
                            )
                        )
                    } else {
                        Color.backGround.ignoresSafeArea()
                            .onAppear { appState.signOut() }
                    }

                case .accountVerified:
                    AccountVerifiedView(
                        viewModel: diContainer.makeAccountVerifiedViewModel(
                            onStartJourney: { appState.startHomeFlow() }
                        )
                    )

                case .home:
                    MainTabCoordinatorView(container: diContainer, appState: appState)
                }
            }
            .task {
                // Run the startup verification check
                await appState.checkVerificationStatus(
                    getNurseUseCase: diContainer.makeGetNurseUseCase(),
                    tokenStore: diContainer.tokenStore
                )
            }
        }
    }
}
