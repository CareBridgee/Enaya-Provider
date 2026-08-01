//
//  UpdatePersonalInfoUseCase.swift
//  EnayaProvider
//

import Foundation

protocol UpdatePersonalInfoUseCaseProtocol: Sendable {
    func execute(info: PersonalInfo) async throws
}

struct UpdatePersonalInfoUseCase: UpdatePersonalInfoUseCaseProtocol {
    private let repository: ProfileSetupRepositoryProtocol
    private let mediaUploadService: MediaUploadServiceProtocol
    private let sessionManager: SessionManager
    
    init(
        repository: ProfileSetupRepositoryProtocol,
        mediaUploadService: MediaUploadServiceProtocol,
        sessionManager: SessionManager
    ) {
        self.repository = repository
        self.mediaUploadService = mediaUploadService
        self.sessionManager = sessionManager
    }
    
    func execute(info: PersonalInfo) async throws {
        var profileImageUrl: String? = nil
        
        // 1. Upload Profile Photo if it exists
        if let photoData = info.profilePhotoData {
            let fileName = "profile_\(UUID().uuidString).jpg"
            profileImageUrl = try await mediaUploadService.uploadMedia(
                data: photoData,
                fileName: fileName,
                mimeType: "image/jpeg"
            )
        }
        
        // 2. Update backend with new info and image URL
        let updatedUser = try await repository.updatePersonalInfo(
            info: info,
            profileImageUrl: profileImageUrl
        )
        
        // 3. Update SessionManager with new user data
        await MainActor.run {
            sessionManager.setLoggedIn(with: updatedUser)
        }
    }
}
