//
//  AppSettings.swift
//  EnayaProvider
//
//  Created by Mona Zarea on 31/07/2026.
//

import Foundation
import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

protocol AppSettingsProtocol: AnyObject {
    var hasSeenOnboarding: Bool { get set }
    var applicationStatus: String? { get set }
    var appearance: AppAppearance { get set }
}

final class AppSettings: AppSettingsProtocol {
    static let shared = AppSettings()
    
    private let defaults = UserDefaults.standard
    
    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    private let applicationStatusKey = "applicationStatus"
    private let appearanceKey = "app_appearance"
    
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
    
    var appearance: AppAppearance {
        get {
            guard let raw = defaults.string(forKey: appearanceKey),
                  let val = AppAppearance(rawValue: raw) else {
                return .system
            }
            return val
        }
        set {
            defaults.set(newValue.rawValue, forKey: appearanceKey)
        }
    }
    
    private init() {}
}
