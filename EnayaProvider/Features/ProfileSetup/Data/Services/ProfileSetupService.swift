//
//  ProfileSetupService.swift
//  EnayaProvider
//
//  Created by Mohamed Ayman on 05/08/2026.
//

import Foundation
import Alamofire

protocol ProfileSetupServiceProtocol {
    func getServiceTypes() async throws -> [ServiceTypeDTO]
    func updateUserProfile(
        firstName: String,
        lastName: String,
        email: String?,
        dateOfBirth: String?,
        gender: String?,
        profileImageUrl: String?,
        profileImage: UploadedDocument?
    ) async throws -> UserDTO
    func registerNurse(
        bio: String?,
        licenseNumber: String?,
        specialization: String?,
        nationalId: String?,
        yearsOfExperience: Int?,
        professionalCertificate: UploadedDocument?,
        nationalIdBack: UploadedDocument?,
        licenseImage: UploadedDocument?,
        nationalIdFront: UploadedDocument?,
        profileImage: UploadedDocument?
    ) async throws -> NurseRegistrationResponseDTO
    func addNurseService(nurseId: String, request: [NurseServiceRequestDTO]) async throws -> NurseServiceBulkResponseDTO
    func uploadDocument(data: Data, fileName: String, mimeType: String) async throws -> UploadResponseDTO
}

final class ProfileSetupServiceImpl: ProfileSetupServiceProtocol {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    func getServiceTypes() async throws -> [ServiceTypeDTO] {
        return try await networkClient.request(ProfileSetupEndpoint.getServiceTypes)
    }
    
    func updateUserProfile(
        firstName: String,
        lastName: String,
        email: String?,
        dateOfBirth: String?,
        gender: String?,
        profileImageUrl: String?,
        profileImage: UploadedDocument?
    ) async throws -> UserDTO {
        return try await networkClient.upload(ProfileSetupEndpoint.updateUserProfile) { multipartFormData in
            if let data = firstName.data(using: .utf8) { multipartFormData.append(data, withName: "firstName") }
            if let data = lastName.data(using: .utf8) { multipartFormData.append(data, withName: "lastName") }
            if let email = email, let data = email.data(using: .utf8) { multipartFormData.append(data, withName: "email") }
            if let dob = dateOfBirth, let data = dob.data(using: .utf8) { multipartFormData.append(data, withName: "dateOfBirth") }
            if let gender = gender, let data = gender.data(using: .utf8) { multipartFormData.append(data, withName: "gender") }
            if let url = profileImageUrl, let data = url.data(using: .utf8) { multipartFormData.append(data, withName: "profileImageUrl") }
            
            if let document = profileImage {
                multipartFormData.append(
                    document.data,
                    withName: "profileImage",
                    fileName: document.fileName,
                    mimeType: self.mimeType(for: document.fileName)
                )
            }
        }
    }
    
    func registerNurse(
        bio: String?,
        licenseNumber: String?,
        specialization: String?,
        nationalId: String?,
        yearsOfExperience: Int?,
        professionalCertificate: UploadedDocument?,
        nationalIdBack: UploadedDocument?,
        licenseImage: UploadedDocument?,
        nationalIdFront: UploadedDocument?,
        profileImage: UploadedDocument?
    ) async throws -> NurseRegistrationResponseDTO {
        
        return try await networkClient.upload(ProfileSetupEndpoint.registerNurse) { multipartFormData in
            if let bio = bio?.data(using: .utf8) {
                multipartFormData.append(bio, withName: "bio")
            }
            if let licenseNumber = licenseNumber?.data(using: .utf8) {
                multipartFormData.append(licenseNumber, withName: "licenseNumber")
            }
            if let specialization = specialization?.data(using: .utf8) {
                multipartFormData.append(specialization, withName: "specialization")
            }
            if let nationalId = nationalId?.data(using: .utf8) {
                multipartFormData.append(nationalId, withName: "nationalId")
            }
            if let exp = yearsOfExperience {
                if let expData = "\(exp)".data(using: .utf8) {
                    multipartFormData.append(expData, withName: "yearsOfExperience")
                }
            }
            if let document = professionalCertificate {
                multipartFormData.append(
                    document.data,
                    withName: "professionalCertificate",
                    fileName: document.fileName,
                    mimeType: self.mimeType(for: document.fileName)
                )
            }

            if let document = nationalIdFront {
                multipartFormData.append(
                    document.data,
                    withName: "nationalIdFront",
                    fileName: document.fileName,
                    mimeType: self.mimeType(for: document.fileName)
                )
            }

            if let document = nationalIdBack {
                multipartFormData.append(
                    document.data,
                    withName: "nationalIdBack",
                    fileName: document.fileName,
                    mimeType: self.mimeType(for: document.fileName)
                )
            }

            if let document = licenseImage {
                multipartFormData.append(
                    document.data,
                    withName: "licenseImage",
                    fileName: document.fileName,
                    mimeType: self.mimeType(for: document.fileName)
                )
            }

            if let document = profileImage {
                multipartFormData.append(
                    document.data,
                    withName: "profileImage",
                    fileName: document.fileName,
                    mimeType: self.mimeType(for: document.fileName)
                )
            }
        }
    }
    
    func addNurseService(nurseId: String, request: [NurseServiceRequestDTO]) async throws -> NurseServiceBulkResponseDTO {
        return try await networkClient.requestWithBody(ProfileSetupEndpoint.addNurseService(nurseId: nurseId), body: request)
    }
    
    func uploadDocument(data: Data, fileName: String, mimeType: String) async throws -> UploadResponseDTO {
        return try await networkClient.upload(ProfileSetupEndpoint.uploadDocument) { multipartFormData in
            multipartFormData.append(data, withName: "file", fileName: fileName, mimeType: mimeType)
        }
    }
    
    private func mimeType(for fileName: String) -> String {
        switch (fileName as NSString).pathExtension.lowercased() {
        case "pdf":
            return "application/pdf"
        case "png":
            return "image/png"
        case "jpg", "jpeg":
            return "image/jpeg"
        default:
            return "application/octet-stream"
        }
    }
}
