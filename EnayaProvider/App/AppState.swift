//
//  AppState.swift
//  Carely
//
//  Created by Mohamed Ayman on 16/07/2026.
//

import SwiftUI
import Foundation

enum AppFlow: Equatable {
    case auth
    case profileSetup
    case underReview
    case rejected
    case home
}

final class AppState: ObservableObject {

    @Published private(set) var flow: AppFlow

    private static let signedInKey = "isSignedIn"
    private static let applicationStatusKey = "applicationStatus"

    init() {
        let isSignedIn = UserDefaults.standard.bool(forKey: Self.signedInKey)
        if isSignedIn,
           let rawStatus = UserDefaults.standard.string(forKey: Self.applicationStatusKey),
           let status = ApplicationStatus(rawValue: rawStatus) {
            self.flow = Self.flow(for: status)
        } else {
            self.flow = .auth
        }
    }

    func completeAuth(with status: ApplicationStatus) {
        UserDefaults.standard.set(true, forKey: Self.signedInKey)
        UserDefaults.standard.set(status.rawValue, forKey: Self.applicationStatusKey)
        flow = Self.flow(for: status)
    }

    func signOut() {
        UserDefaults.standard.set(false, forKey: Self.signedInKey)
        UserDefaults.standard.removeObject(forKey: Self.applicationStatusKey)
        flow = .auth
    }

    func startHomeFlow() {
            flow = .home
        }

    private static func flow(for status: ApplicationStatus) -> AppFlow {
        switch status {
        case .incomplete: return .profileSetup
        case .underReview: return .underReview
        case .approved: return .home
        case .rejected: return .rejected
        }
    }
}
