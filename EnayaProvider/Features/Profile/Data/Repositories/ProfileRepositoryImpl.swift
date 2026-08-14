//
//  ProfileRepositoryImpl.swift
//  EnayaProvider
//
//  Created by AI.
//

import Foundation

final class ProfileRepositoryImpl: ProfileRepositoryProtocol {
    private let profileService: ProfileServiceProtocol

    init(profileService: ProfileServiceProtocol) {
        self.profileService = profileService
    }

    func getProfile(id: String) async throws -> ProfileEntity {
        let response = try await profileService.getProfile(id: id)
        return mapToEntity(response: response)
    }
    
    func updateProfile(id: String, bio: String, specialization: String, yearsOfExperience: Int) async throws -> ProfileEntity {
        let response = try await profileService.updateProfile(id: id, bio: bio, specialization: specialization, yearsOfExperience: yearsOfExperience)
        return mapToEntity(response: response)
    }
    
    func updateProfileImage(id: String, imageData: Data) async throws -> ProfileEntity {
        let response = try await profileService.updateProfileImage(id: id, imageData: imageData)
        return mapToEntity(response: response)
    }
    
    func updateDocument(id: String, type: DocumentUploadType, imageData: Data) async throws -> ProfileEntity {
        let response = try await profileService.updateDocument(id: id, type: type, imageData: imageData)
        return mapToEntity(response: response)
    }
    
    func getReviews(id: String, page: Int, size: Int) async throws -> PaginatedReviewsEntity {
        let response = try await profileService.getReviews(id: id, page: page, size: size)
        return mapToPaginatedReviewsEntity(response: response)
    }
    
    private func mapToEntity(response: NurseProfileResponseDTO) -> ProfileEntity {
        return ProfileEntity(
            id: response.id,
            firstName: response.firstName,
            lastName: response.lastName,
            profileImageUrl: response.profileImageUrl,
            specialization: response.specialization,
            ratingAvg: response.ratingAvg,
            totalReviews: response.totalReviews,
            yearsOfExperience: response.yearsOfExperience ?? 0,
            bio: response.bio,
            services: response.services?.map { $0.serviceName.replacingOccurrences(of: "\"", with: "") } ?? [],
            nationalIdFrontUrl: response.nationalIdFrontUrl,
            nationalIdBackUrl: response.nationalIdBackUrl,
            licenseImageUrl: response.licenseImageUrl,
            professionalCertificateUrl: response.professionalCertificateUrl,
            verificationStatus: response.verificationStatus
        )
    }
    
    private func mapToPaginatedReviewsEntity(response: PaginatedReviewsDTO) -> PaginatedReviewsEntity {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let reviews = response.content.map { dto -> ReviewEntity in
            let date = formatter.date(from: dto.createdAt) ?? Date()
            
            // Mocking name and service name as they are not provided by the API
            let name = dto.isAnonymous ? "Anonymous" : "Patient"
            let serviceName = "Completed Service"
            
            return ReviewEntity(
                id: dto.id,
                rating: dto.rating,
                reviewText: dto.reviewText,
                isAnonymous: dto.isAnonymous,
                createdAt: date,
                reviewerName: name,
                serviceName: serviceName
            )
        }
        
        return PaginatedReviewsEntity(
            totalElements: response.totalElements,
            totalPages: response.totalPages,
            pageNumber: response.pageable.pageNumber,
            pageSize: response.pageable.pageSize,
            isLastPage: response.last,
            reviews: reviews
        )
    }
}
