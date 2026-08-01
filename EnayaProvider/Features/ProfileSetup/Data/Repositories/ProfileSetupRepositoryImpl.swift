//
//  ProfileSetupRepositoryImpl.swift
//  Carely
//
//  Created by Mohamed Ayman on 19/07/2026.
//
import Foundation

final class ProfileSetupRepositoryImpl: ProfileSetupRepositoryProtocol {
    private let simulatedDelayNanoseconds: UInt64 = 1_200_000_000
    private let profileSetupService: ProfileSetupServiceProtocol
    
    init(profileSetupService: ProfileSetupServiceProtocol) {
        self.profileSetupService = profileSetupService
    }

    func submitApplication(_ data: ProfileSetupData) async throws {
        try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
    }
    
    func updatePersonalInfo(info: PersonalInfo, profileImageUrl: String?) async throws -> UserDTO {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dobString = info.dateOfBirth.map { formatter.string(from: $0) } ?? ""
        
        let request = UpdatePersonalInfoRequest(
            firstName: info.firstName,
            lastName: info.lastName,
            email: nil, // If email is available in the future, add it here
            dateOfBirth: dobString,
            gender: info.gender ?? .male, // Fallback if nil
            profileImageUrl: profileImageUrl
        )
        return try await profileSetupService.updatePersonalInfo(request: request)
    }
    
    func registerNurse(request: RegisterNurseRequest) async throws -> NurseDTO {
        return try await profileSetupService.registerNurse(request: request)
    }
}
