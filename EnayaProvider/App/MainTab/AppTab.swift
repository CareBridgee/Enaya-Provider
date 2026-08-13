//
//  AppTab.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import Foundation


enum AppTab: CaseIterable {
    case home
    case activeJobs
    case wallet
    case profile

}

extension AppTab {
    var title: String {
        switch self {
        case .home: return "Home"
        case .profile: return "Profile"
        case .activeJobs: return "Jobs"
        case .wallet: return "Earnings"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .profile: return "person"
        case .activeJobs: return "briefcase"
        case .wallet: return "wallet.pass"
        }
    }
}
