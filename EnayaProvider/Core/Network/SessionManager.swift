//
//  SessionManager.swift
//  Carely
//
//  Created by Mohamed Ayman on 25/07/2026.
//

import Foundation
import Combine

enum SessionState: Equatable {
    case loggedOut
    case loggedIn
    case expired
}

protocol SessionMonitor: Sendable {
    func sessionDidExpire()
}

@MainActor
final class SessionManager: ObservableObject, SessionMonitor {
    @Published private(set) var state: SessionState

    @Published private(set) var currentUser: UserDTO?

    private let tokenStore: TokenStoring
    private let userStore: UserStoring

    init(tokenStore: TokenStoring, userStore: UserStoring) {
        self.tokenStore = tokenStore
        self.userStore = userStore
        self.currentUser = userStore.getUser()
        self.state = tokenStore.getAccessToken() != nil ? .loggedIn : .loggedOut
    }

    func setLoggedIn(with user: UserDTO) {
        userStore.saveUser(user)
        self.currentUser = user
        state = .loggedIn
    }

    func setLoggedOut() {
        tokenStore.clearTokens()
        userStore.clearUser()
        self.currentUser = nil
        state = .loggedOut
    }

    nonisolated func sessionDidExpire() {
        Task { @MainActor in
            self.state = .expired
            // Note: In real app, we might want to keep the user data until explicit logout,
            // or clear it if session expires. Usually we keep it for faster re-login.
        }
    }
}
