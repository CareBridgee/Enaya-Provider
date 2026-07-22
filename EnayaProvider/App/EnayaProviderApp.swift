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
    @StateObject private var appState = AppState()

    @MainActor
    init() {
        self.diContainer = DIContainer()
    }

    var body: some Scene {
            WindowGroup {
                switch appState.flow {

                case .auth:
                    AuthCoordinator(container: diContainer, appState: appState)

                case .profileSetup:
                    ProfileSetupCoordinatorView(
                        container: diContainer,
                        coordinator: diContainer.makeProfileSetupCoordinator(),
                        onFinish: { appState.completeAuth(with: .underReview) }
                    )

                case .underReview:
                    UnderReviewView(
                        viewModel: diContainer.makeUnderReviewViewModel(
                            onBackToLogin: { appState.signOut() }
                        )
                    )

                case .accountVerified:
                    AccountVerifiedView(
                        viewModel: diContainer.makeAccountVerifiedViewModel(
                            onStartJourney: { appState.startHomeFlow() }
                        )
                    )

                case .rejected:
                    DocumentRejectedView(
                        viewModel: diContainer.makeDocumentRejectedViewModel(
                            onUploadAgain: { appState.startProfileSetup() }
                        )
                    )

                case .home:
                    ContentView()
                }
            }
        }
}
