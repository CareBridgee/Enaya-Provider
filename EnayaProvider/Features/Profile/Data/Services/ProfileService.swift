//
//  ProfileService.swift
//  EnayaProvider
//
//  Created by AI.
//

import Foundation

protocol ProfileServiceProtocol {
    func getProfile(id: String) async throws -> NurseProfileResponseDTO
    func updateProfile(id: String, bio: String, specialization: String, yearsOfExperience: Int) async throws -> NurseProfileResponseDTO
    func updateProfileImage(id: String, imageData: Data) async throws -> NurseProfileResponseDTO
    func updateDocument(id: String, type: DocumentUploadType, imageData: Data) async throws -> NurseProfileResponseDTO
    func getReviews(id: String, page: Int, size: Int) async throws -> PaginatedReviewsDTO
}

enum DocumentUploadType: String {
    case nationalIdFront = "nationalIdFront"
    case nationalIdBack = "nationalIdBack"
    case licenseImage = "licenseImage"
    case professionalCertificate = "professionalCertificate"
}

final class ProfileServiceImpl: ProfileServiceProtocol {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func getProfile(id: String) async throws -> NurseProfileResponseDTO {
        return try await networkClient.request(ProfileEndpoint.getProfile(id: id))
    }
    
    func updateProfile(id: String, bio: String, specialization: String, yearsOfExperience: Int) async throws -> NurseProfileResponseDTO {
        return try await networkClient.upload(ProfileEndpoint.updateProfile(id: id)) { multipartFormData in
            if let bioData = bio.data(using: .utf8) {
                multipartFormData.append(bioData, withName: "bio")
            }
            if let specializationData = specialization.data(using: .utf8) {
                multipartFormData.append(specializationData, withName: "specialization")
            }
            if let experienceData = "\(yearsOfExperience)".data(using: .utf8) {
                multipartFormData.append(experienceData, withName: "yearsOfExperience")
            }
        }
    }
    
    func updateProfileImage(id: String, imageData: Data) async throws -> NurseProfileResponseDTO {
        return try await networkClient.upload(ProfileEndpoint.updateProfile(id: id)) { multipartFormData in
            multipartFormData.append(imageData, withName: "profileImage", fileName: "profile_image.jpg", mimeType: "image/jpeg")
        }
    }
    
    func updateDocument(id: String, type: DocumentUploadType, imageData: Data) async throws -> NurseProfileResponseDTO {
        return try await networkClient.upload(ProfileEndpoint.updateProfile(id: id)) { multipartFormData in
            multipartFormData.append(imageData, withName: type.rawValue, fileName: "\(type.rawValue).jpg", mimeType: "image/jpeg")
        }
    }
    
    func getReviews(id: String, page: Int, size: Int) async throws -> PaginatedReviewsDTO {
        return try await networkClient.request(ProfileEndpoint.getReviews(id: id, page: page, size: size))
    }
}
