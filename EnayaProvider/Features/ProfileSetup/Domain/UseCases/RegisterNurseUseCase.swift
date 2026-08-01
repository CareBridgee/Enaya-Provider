//
//  RegisterNurseUseCase.swift
//  EnayaProvider
//

import Foundation

protocol RegisterNurseUseCaseProtocol: Sendable {
    func execute(info: ProfessionalInfo, personalInfo: PersonalInfo) async throws
}

struct RegisterNurseUseCase: RegisterNurseUseCaseProtocol {
    private let repository: ProfileSetupRepositoryProtocol
    private let sessionManager: SessionManager
    
    init(
        repository: ProfileSetupRepositoryProtocol,
        sessionManager: SessionManager
    ) {
        self.repository = repository
        self.sessionManager = sessionManager
    }
    
    func execute(info: ProfessionalInfo, personalInfo: PersonalInfo) async throws {
        
        guard let nationalId = personalInfo.nationalId.isEmpty ? nil : personalInfo.nationalId else {
            throw NSError(domain: "RegisterNurseUseCase", code: 400, userInfo: [NSLocalizedDescriptionKey: "National ID is missing from Personal Info"])
        }
        
        guard let licenseNumber = info.licenseNumber, !licenseNumber.isEmpty else {
            throw NSError(domain: "RegisterNurseUseCase", code: 400, userInfo: [NSLocalizedDescriptionKey: "License number is missing"])
        }
        
        guard let specialty = info.primarySpecialty?.rawValue else {
            throw NSError(domain: "RegisterNurseUseCase", code: 400, userInfo: [NSLocalizedDescriptionKey: "Specialty is missing"])
        }
        
        guard let yearsOfExperience = info.yearsOfExperience else {
            throw NSError(domain: "RegisterNurseUseCase", code: 400, userInfo: [NSLocalizedDescriptionKey: "Years of experience is missing"])
        }
        
        let yearsInt: Int
        switch yearsOfExperience {
        case .lessThanOne: yearsInt = 0
        case .oneToThree: yearsInt = 2
        case .threeToFive: yearsInt = 4
        case .fiveToTen: yearsInt = 7
        case .tenPlus: yearsInt = 10
        }
        
        guard let nationalIdFront = info.nationalIdDocument?.data,
              let nationalIdBack = info.nationalIdBackDocument?.data,
              let licenseImage = info.nursingLicenseDocument?.data,
              let professionalCertificate = info.professionalCertificateDocument?.data else {
            throw NSError(domain: "RegisterNurseUseCase", code: 400, userInfo: [NSLocalizedDescriptionKey: "One or more required documents are missing"])
        }
        
        let request = RegisterNurseRequest(
            nationalId: nationalId,
            licenseNumber: licenseNumber,
            specialization: specialty,
            yearsOfExperience: yearsInt,
            bio: info.bio,
            nationalIdFront: nationalIdFront,
            nationalIdBack: nationalIdBack,
            licenseImage: licenseImage,
            professionalCertificate: professionalCertificate
        )
        
        let nurseDTO = try await repository.registerNurse(request: request)
        
        // Update user in SessionManager with the newly registered nurse info
        await MainActor.run {
            if let currentUser = sessionManager.currentUser {
                let updatedUser = UserDTO(
                    id: currentUser.id,
                    phoneNumber: currentUser.phoneNumber,
                    email: currentUser.email,
                    firstName: currentUser.firstName,
                    lastName: currentUser.lastName,
                    dateOfBirth: currentUser.dateOfBirth,
                    gender: currentUser.gender,
                    profileImageUrl: currentUser.profileImageUrl,
                    isDeleted: currentUser.isDeleted,
                    createdAt: currentUser.createdAt,
                    updatedAt: currentUser.updatedAt,
                    lastLoginAt: currentUser.lastLoginAt,
                    defaultProfileId: currentUser.defaultProfileId,
                    nurse: nurseDTO
                )
                sessionManager.setLoggedIn(with: updatedUser)
            }
        }
    }
}
