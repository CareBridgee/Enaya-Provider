//
//  ProfileSetupRepositoryImpl.swift
//  Carely
//
//  Created by Mohamed Ayman on 19/07/2026.
//
import Foundation
import UIKit

final class ProfileSetupRepositoryImpl: ProfileSetupRepositoryProtocol {
    private let profileService: ProfileSetupServiceProtocol
    private let cloudinaryService: CloudinaryUploadServiceProtocol

    init(profileService: ProfileSetupServiceProtocol, cloudinaryService: CloudinaryUploadServiceProtocol) {
        self.profileService = profileService
        self.cloudinaryService = cloudinaryService
    }
    
    func getServiceTypes() async throws -> [CareService] {
        let dtos = try await profileService.getServiceTypes()
        return dtos.map { dto in
            CareService(
                id: dto.id,
                title: dto.name,
                description: dto.description,
                iconUrl: dto.imageUrl,
                category: dto.category,
                basePrice: dto.basePrice
            )
        }
    }

    private func uploadDocument(_ doc: UploadedDocument) async throws -> String {
        let mimeType: String
        let ext = (doc.fileName as NSString).pathExtension.lowercased()
        if ext == "pdf" {
            mimeType = "application/pdf"
        } else if ext == "png" {
            mimeType = "image/png"
        } else {
            mimeType = "image/jpeg"
        }
        
        let response = try await profileService.uploadDocument(data: doc.data, fileName: doc.fileName, mimeType: mimeType)
        return response.url
    }

    func submitApplication(_ data: ProfileSetupData) async throws {
        var profilePhotoUrl: String? = nil
        if let photoData = data.personalInfo.profilePhotoData, let image = UIImage(data: photoData) {
            let response = try await cloudinaryService.uploadImage(image, compressionQuality: 0.8)
            profilePhotoUrl = response.secureUrl
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let nurseResponse = try await profileService.registerNurse(
            bio: nil,
            licenseNumber: data.personalInfo.licenseNumber,
            specialization: data.professionalInfo.primarySpecialty?.rawValue,
            nationalId: data.personalInfo.nationalId,
            yearsOfExperience: 1,
            professionalCertificate: data.professionalInfo.professionalCertificateDocument,
            nationalIdBack: data.professionalInfo.nationalIdBack,
            licenseImage: data.professionalInfo.nursingLicenseDocument,
            nationalIdFront: data.professionalInfo.nationalIdFront,
            profileImage: data.personalInfo.profilePhotoData != nil ? UploadedDocument(fileName: "profile_image.jpg", data: data.personalInfo.profilePhotoData!) : nil
        )

        _ = try await profileService.updateUserProfile(
            firstName: data.personalInfo.firstName,
            lastName: data.personalInfo.lastName,
            email: nil,
            dateOfBirth: data.personalInfo.dateOfBirth.map { formatter.string(from: $0) },
            gender: data.personalInfo.gender?.rawValue,
            profileImageUrl: profilePhotoUrl,
            profileImage: data.personalInfo.profilePhotoData != nil ? UploadedDocument(fileName: "profile_image.jpg", data: data.personalInfo.profilePhotoData!) : nil
        )
        let requests = data.providedServices.selectedServices.map { NurseServiceRequestDTO(serviceTypeId: $0.id) }
        _ = try await profileService.addNurseService(nurseId: nurseResponse.id, request: requests)
    }
}
