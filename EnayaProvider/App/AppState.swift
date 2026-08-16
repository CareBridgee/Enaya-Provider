//
//  AppState.swift
//  EnayaProvider
//
//  Created by Mohamed Ayman on 16/07/2026.
//
import SwiftUI
import Foundation
import Combine

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
    @Published private(set) var appearance: AppAppearance

    private let sessionManager: SessionManager
    private var appSettings: AppSettingsProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(sessionManager: SessionManager, appSettings: AppSettingsProtocol = AppSettings.shared) {
        self.sessionManager = sessionManager
        self.appSettings = appSettings
        self.appearance = appSettings.appearance
        
        if sessionManager.state == .loggedIn,
           let rawStatus = appSettings.applicationStatus,
           let status = ApplicationStatus(rawValue: rawStatus) {
            // Already-approved nurses skip the one-time celebration screen on relaunch.
            self.flow = status == .approved ? .home : Self.flow(for: status)
        } else {
            self.flow = .auth
        }
        
        sessionManager.$state
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                if state == .loggedOut || state == .expired {
                    self?.signOut()
                }
            }
            .store(in: &cancellables)
    }

    func setAppearance(_ newAppearance: AppAppearance) {
        appSettings.appearance = newAppearance
        appearance = newAppearance
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
    
    func checkVerificationStatus(getNurseUseCase: GetNurseUseCaseProtocol, tokenStore: TokenStoring) async {
        guard sessionManager.state == .loggedIn else {
            await MainActor.run { flow = .auth }
            return
        }
        
        guard let nurseId = tokenStore.getNurseId() else {
            await MainActor.run { flow = .auth }
            return
        }
        
        do {
            let nurse = try await getNurseUseCase.execute(nurseId: nurseId)
            await MainActor.run {
                appSettings.applicationStatus = nurse.verificationStatus.rawValue
                flow = Self.flow(for: nurse.verificationStatus)
            }
        } catch {
            await MainActor.run { flow = .auth }
        }
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
