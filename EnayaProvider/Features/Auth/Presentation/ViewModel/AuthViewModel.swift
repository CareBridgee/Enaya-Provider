//
//  WelcomeViewModel.swift
//  Carely
//
//  Created by Mona Zarea on 15/07/2026.
//

import Foundation
import UIKit
import GoogleSignIn

@MainActor
final class WelcomeViewModel: ObservableObject {

    private let router: AuthRouter
    private let repository: AuthRepositoryProtocol
    private let tokenStore: TokenStoring
    private let sessionManager: SessionManager
    private let onAuthFinished: (ApplicationStatus) -> Void

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let webClientID = "588669996312-j7mtte5q10a1lcsu4jfn4g18n9gri40e.apps.googleusercontent.com"
    private let iosClientID = "588669996312-4jm91t591o9ej3q045d7a0adbdk29vdr.apps.googleusercontent.com"

    init(
        router: AuthRouter,
        repository: AuthRepositoryProtocol,
        tokenStore: TokenStoring,
        sessionManager: SessionManager,
        onAuthFinished: @escaping (ApplicationStatus) -> Void
    ) {
        self.router = router
        self.repository = repository
        self.tokenStore = tokenStore
        self.sessionManager = sessionManager
        self.onAuthFinished = onAuthFinished
    }

        func continueWithPhone() {
            router.push(to: .PhoneNumber(pendingToken: nil)) 
        }

        
    func continueWithGoogle(presentingWindow: UIViewController) {
        isLoading = true
        errorMessage = nil

        let config = GIDConfiguration(clientID: iosClientID, serverClientID: webClientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingWindow) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                return
            }

            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                self.isLoading = false
                self.errorMessage = "Failed to obtain ID token from Google."
                return
            }

            Task {
                await self.authenticateWithBackend(idToken: idToken)
            }
        }
    }

    private func authenticateWithBackend(idToken: String) async {
            do {
                let response = try await repository.googleNurseLogin(idToken: idToken)
                isLoading = false

                if response.status == "AUTHENTICATED" {
                    guard let access = response.accessToken, let refresh = response.refreshToken else { return }
                    tokenStore.saveTokens(access: access, refresh: refresh)
                    
                    if let nurseId = response.nurseUser?.nurse?.id {
                        tokenStore.saveNurseId(nurseId)
                    }
                    
                    sessionManager.setLoggedIn()
                    
                    let statusRaw = response.nurseUser?.nurse?.verificationStatus ?? "INCOMPLETE"
                    let status = ApplicationStatus(rawValue: statusRaw) ?? .incomplete
                    let isNewUser = response.nurseUser?.firstName == "Nurse" && (response.nurseUser?.lastName?.isEmpty ?? true)
                    let finalStatus = isNewUser ? .incomplete : status
                    
                    onAuthFinished(finalStatus)
                    
                } else if response.status == "PHONE_REQUIRED" {
                    print("🟢 [Auth Flow 1]: Google Login returned PHONE_REQUIRED. Pending Token: \(response.pendingToken ?? "nil")")
                    router.push(to: .PhoneNumber(pendingToken: response.pendingToken))
                }
            } catch {
                isLoading = false
                self.errorMessage = (error as? AuthError)?.errorDescription ?? error.localizedDescription
            }
        }
}
