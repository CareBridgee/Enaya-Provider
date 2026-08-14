//
//  EditBioViewModel.swift
//  EnayaProvider
//
//  Created by AI.
//

import Foundation

@MainActor
final class EditBioViewModel: ObservableObject {
    @Published var bio: String
    @Published var specialization: String
    @Published var yearsOfExperience: String
    
    @Published var isLoading = false
    @Published var error: Error?
    
    private let profileId: String
    private let updateProfileUseCase: UpdateProfileUseCaseProtocol
    private let onSuccess: (ProfileEntity) -> Void
    
    init(
        profileId: String,
        initialBio: String?,
        initialSpecialization: String?,
        initialYearsOfExperience: Int,
        updateProfileUseCase: UpdateProfileUseCaseProtocol,
        onSuccess: @escaping (ProfileEntity) -> Void
    ) {
        self.profileId = profileId
        self.bio = initialBio ?? ""
        self.specialization = initialSpecialization ?? ""
        self.yearsOfExperience = "\(initialYearsOfExperience)"
        self.updateProfileUseCase = updateProfileUseCase
        self.onSuccess = onSuccess
    }
    
    func save() {
        Task {
            isLoading = true
            error = nil
            do {
                let experience = Int(yearsOfExperience) ?? 0
                let updatedProfile = try await updateProfileUseCase.execute(
                    id: profileId,
                    bio: bio,
                    specialization: specialization,
                    yearsOfExperience: experience
                )
                isLoading = false
                onSuccess(updatedProfile)
            } catch {
                self.error = error
                isLoading = false
            }
        }
    }
}
