//
//  AuthCoordinator.swift
//  Carely
//
//  Created by Mohamed Ayman on 16/07/2026.
//
import Foundation
import SwiftUI

struct AuthCoordinator: View {
    let container: DIContainer
    let appState: AppState

    @StateObject private var router = AuthRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            WelcomeView(viewModel: container.makeWelcomeViewModel(router: router))
                .navigationDestination(for: AuthRoute.self) { route in
                    destination(for: route)
                }
        }
    }

    @ViewBuilder
    private func destination(for route: AuthRoute) -> some View {
        switch route {

        case .PhoneNumber:
            PhoneNumberView(viewModel: container.makePhoneNumberViewModel(router: router))

        case .OTPVerification(let phoneNumber):
            OTPVerificationView(
                viewModel: container.makeOTPVerificationViewModel(
                    phoneNumber: phoneNumber,
                    router: router,
                    onAuthFinished: { status in
                        appState.completeAuth(with: status)
                    }
                )
            )
        }
    }
}
