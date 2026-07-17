//
//  EnayaProviderApp.swift
//  EnayaProvider
//
//  Created by Mona Zarea on 16/07/2026.
//

import SwiftUI

@main
struct EnayaProviderApp: App {
    let diContainer :DIContainer
    @StateObject private var appState = AppState()
    
    @MainActor
    init() {
        self.diContainer = DIContainer()
    }
    
    var body: some Scene {
        WindowGroup {
            if appState.phase == .auth {
                AuthCoordinator(container: diContainer) { appState.signIn() }
            } else {
                ContentView()
            }
        }
    }
}
