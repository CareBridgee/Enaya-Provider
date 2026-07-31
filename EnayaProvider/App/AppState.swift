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
    case accountVerified
    case rejected
    case home
}
@MainActor
final class AppState: ObservableObject {

    @Published private(set) var flow: AppFlow

    private let sessionManager: SessionManager
    private var appSettings: AppSettingsProtocol
    
    init(sessionManager: SessionManager, appSettings: AppSettingsProtocol = AppSettings.shared) {
        self.sessionManager = sessionManager
        self.appSettings = appSettings
        if sessionManager.state == .loggedIn,
           let rawStatus = appSettings.applicationStatus,
           let status = ApplicationStatus(rawValue: rawStatus) {
            // Already-approved nurses skip the one-time celebration screen on relaunch.
            self.flow = status == .approved ? .home : Self.flow(for: status)
        } else {
            self.flow = .auth
        }
    }

    func completeAuth(with status: ApplicationStatus) {
        appSettings.applicationStatus = status.rawValue
        flow = Self.flow(for: status)
    }

    func signOut() {
        appSettings.applicationStatus = nil
        flow = .auth
    }

    func startHomeFlow() {
        flow = .home
    }

    func startProfileSetup() {
        flow = .profileSetup
    }

    private static func flow(for status: ApplicationStatus) -> AppFlow {
        switch status {
        case .incomplete: return .profileSetup
        case .underReview: return .underReview
        case .approved: return .accountVerified
        case .rejected: return .rejected
        }
    }
}
