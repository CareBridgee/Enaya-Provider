//
//  ProfileSetupRepositoryProtocol.swift
//  Carely
//
//  Created by Mohamed Ayman on 19/07/2026.
//

import Foundation

protocol ProfileSetupRepositoryProtocol: Sendable {
    func submitApplication(_ data: ProfileSetupData) async throws
    func updatePersonalInfo(info: PersonalInfo, profileImageUrl: String?) async throws -> UserDTO
    func registerNurse(request: RegisterNurseRequest) async throws -> NurseDTO
}
