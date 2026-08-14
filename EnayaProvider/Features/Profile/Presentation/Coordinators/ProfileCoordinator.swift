//
//  ProfileCoordinator.swift
//  EnayaProvider
//
//  Created by AI.
//

import Foundation
import SwiftUI

enum ProfileRoute: Hashable {
    case personalInfo(profile: ProfileEntity)
    case documents(profile: ProfileEntity)
    case reviews(nurseId: String, avgRating: Double, totalReviews: Int)
    case settings
}

@MainActor
final class ProfileCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    func push(to route: ProfileRoute) {
        path.append(route)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}
