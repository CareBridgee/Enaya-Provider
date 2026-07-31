//
//  AppSettings.swift
//  EnayaProvider
//
//  Created by Mona Zarea on 31/07/2026.
//

import Foundation

protocol AppSettingsProtocol {
    var hasSeenOnboarding: Bool { get set }
    var applicationStatus: String? {get set}
}

final class AppSettings: AppSettingsProtocol {
    static let shared = AppSettings()
    
    private let defaults = UserDefaults.standard
    
    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    private let applicationStatusKey = "applicationStatus"
    
    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: hasSeenOnboardingKey) }
        set { defaults.set(newValue, forKey: hasSeenOnboardingKey) }
    }
    
    var applicationStatus: String? {
        get { defaults.string(forKey: applicationStatusKey) }
        set {
            if let value = newValue {
                defaults.set(value, forKey: applicationStatusKey)
            } else {
                defaults.removeObject(forKey: applicationStatusKey) 
            }
        }
    }
    
    
    
    private init() {}
}

