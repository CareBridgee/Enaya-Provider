//
//  ProfileSetupService.swift
//  EnayaProvider
//

import Foundation

protocol ProfileSetupServiceProtocol: Sendable {
    func updatePersonalInfo(request: UpdatePersonalInfoRequest) async throws -> UserDTO
    func registerNurse(request: RegisterNurseRequest) async throws -> NurseDTO
}

final class ProfileSetupServiceImpl: ProfileSetupServiceProtocol {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    func updatePersonalInfo(request: UpdatePersonalInfoRequest) async throws -> UserDTO {
        return try await networkClient.request(
            ProfileSetupEndpoint.updatePersonalInfo(request: request)
        )
    }
    
    func registerNurse(request: RegisterNurseRequest) async throws -> NurseDTO {
        return try await networkClient.upload(
            ProfileSetupEndpoint.registerNurse,
            multipartFormData: { multipartFormData in
                // Add text parameters
                if let nationalIdData = request.nationalId.data(using: .utf8) {
                    multipartFormData.append(nationalIdData, withName: "nationalId")
                }
                if let licenseNumberData = request.licenseNumber.data(using: .utf8) {
                    multipartFormData.append(licenseNumberData, withName: "licenseNumber")
                }
                if let specializationData = request.specialization.data(using: .utf8) {
                    multipartFormData.append(specializationData, withName: "specialization")
                }
                if let yearsData = "\(request.yearsOfExperience)".data(using: .utf8) {
                    multipartFormData.append(yearsData, withName: "yearsOfExperience")
                }
                if let bio = request.bio, let bioData = bio.data(using: .utf8) {
                    multipartFormData.append(bioData, withName: "bio")
                }
                
                // Add binary parameters
                multipartFormData.append(request.nationalIdFront, withName: "nationalIdFront", fileName: "nationalIdFront.jpg", mimeType: "image/jpeg")
                multipartFormData.append(request.nationalIdBack, withName: "nationalIdBack", fileName: "nationalIdBack.jpg", mimeType: "image/jpeg")
                multipartFormData.append(request.licenseImage, withName: "licenseImage", fileName: "licenseImage.jpg", mimeType: "image/jpeg")
                multipartFormData.append(request.professionalCertificate, withName: "professionalCertificate", fileName: "professionalCertificate.jpg", mimeType: "image/jpeg")
            }
        )
    }
}
