//
//  AppTab.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import Foundation

enum AppTab: CaseIterable {
    case hub
    case tracker
    case availability
    case earnings
}

extension AppTab {
    var title: String {
        switch self {
        case .hub: return "Hub"
        case .tracker: return "Tracker"
        case .availability: return "Availability"
        case .earnings: return "Earnings"
        }
    }

    var iconName: String {
        switch self {
        case .hub: return "square.grid.2x2.fill"
        case .tracker: return "location.fill"
        case .availability: return "calendar"
        case .earnings: return "creditcard.fill"
        }
    }
}