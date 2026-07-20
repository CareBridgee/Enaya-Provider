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
                // TODO: Phase 5 — replace with real Application Under Review screen.
                Text("Application Under Review")

            case .rejected:
                // TODO: Phase 5 — replace with real Document Rejected screen.
                Text("Document Rejected")

            case .home:
                ContentView()
            }
        }
    }
}
