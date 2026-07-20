//
//  ProfileSetupRepositoryProtocol.swift
//  Carely
//
//  Created by Mohamed Ayman on 19/07/2026.
//

import Foundation

protocol ProfileSetupRepositoryProtocol {
    func submitApplication(_ data: ProfileSetupData) async throws
}
