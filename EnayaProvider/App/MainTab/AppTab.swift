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

    func iconName(isSelected: Bool) -> String {
        switch self {
        case .home: return isSelected ? "house.fill" : "house"
        case .activeJobs: return isSelected ? "briefcase.fill" : "briefcase"
        case .wallet: return isSelected ? "wallet.pass.fill" : "wallet.pass"
        case .profile: return isSelected ? "person.fill" : "person"
        }
    }
}
