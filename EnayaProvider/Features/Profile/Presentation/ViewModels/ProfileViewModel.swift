//
//  ProfileViewModel.swift
//  EnayaProvider
//
//  Created by AI.
//

import Foundation
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: ProfileEntity?
    @Published var isLoading = false
    @Published var isUploadingImage = false
    @Published var isUploadingDocument = false
    @Published var uploadingDocumentType: DocumentUploadType?
    @Published var errorMessage: String?

    private let getProfileUseCase: GetProfileUseCaseProtocol
    private let updateProfileImageUseCase: UpdateProfileImageUseCaseProtocol
    private let updateDocumentUseCase: UpdateDocumentUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    private let tokenStore: TokenStoring
    private let coordinator: ProfileCoordinator

    init(
        getProfileUseCase: GetProfileUseCaseProtocol,
        updateProfileImageUseCase: UpdateProfileImageUseCaseProtocol,
        updateDocumentUseCase: UpdateDocumentUseCaseProtocol,
        logoutUseCase: LogoutUseCaseProtocol,
        tokenStore: TokenStoring,
        coordinator: ProfileCoordinator
    ) {
        self.getProfileUseCase = getProfileUseCase
        self.updateProfileImageUseCase = updateProfileImageUseCase
        self.updateDocumentUseCase = updateDocumentUseCase
        self.logoutUseCase = logoutUseCase
        self.tokenStore = tokenStore
        self.coordinator = coordinator
    }

    func loadProfile() {
        guard let nurseId = tokenStore.getNurseId() else {
            errorMessage = "Nurse ID not found"
            return
        }
        
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let profile = try await getProfileUseCase.execute(id: nurseId)
                self.profile = profile
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func logout() {
        Task {
            do {
                try await logoutUseCase.execute()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func navigateToPersonalInfo() {
        guard let profile = profile else { return }
        coordinator.push(to: .personalInfo(profile: profile))
    }
    
    func navigateToDocuments() {
        guard let profile = profile else { return }
        coordinator.push(to: .documents(profile: profile))
    }
    
    func navigateToReviews() {
        guard let profile = profile else { return }
        coordinator.push(to: .reviews(nurseId: profile.id, avgRating: profile.ratingAvg ?? 0.0, totalReviews: profile.totalReviews ?? 0))
    }
    
    func navigateToSettings() {
        coordinator.push(to: .settings)
    }
    
    func updateProfileImage(data: Data) {
        guard let profileId = profile?.id ?? tokenStore.getNurseId() else { 
            errorMessage = "Nurse ID not found"
            return 
        }
        Task {
            isUploadingImage = true
            errorMessage = nil
            do {
                let updatedProfile = try await updateProfileImageUseCase.execute(id: profileId, imageData: data)
                self.profile = updatedProfile
                NotificationCenter.default.post(name: NSNotification.Name("ProfileImageUpdated"), object: updatedProfile.profileImageUrl)
            } catch {
                errorMessage = error.localizedDescription
            }
            isUploadingImage = false
        }
    }
    
    func uploadDocument(type: DocumentUploadType, data: Data) {
        print("ProfileViewModel: uploadDocument called for type: \(type.rawValue) with data size: \(data.count)")
        guard let profileId = profile?.id ?? tokenStore.getNurseId() else { 
            print("ProfileViewModel: profile is nil and nurseId not found in tokenStore! Aborting upload.")
            errorMessage = "Profile ID not found"
            return 
        }
        Task {
            print("ProfileViewModel: Starting upload task for \(type.rawValue)")
            isUploadingDocument = true
            uploadingDocumentType = type
            errorMessage = nil
            do {
                let updatedProfile = try await updateDocumentUseCase.execute(id: profileId, type: type, imageData: data)
                print("ProfileViewModel: Upload successful!")
                self.profile = updatedProfile
            } catch {
                print("ProfileViewModel: Upload failed with error: \(error)")
                errorMessage = error.localizedDescription
            }
            isUploadingDocument = false
            uploadingDocumentType = nil
            print("ProfileViewModel: Finished upload task")
        }
    }
}
