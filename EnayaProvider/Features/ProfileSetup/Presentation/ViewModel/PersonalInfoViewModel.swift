//
//  PersonalInfoViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import Foundation
import PhotosUI
import SwiftUI

@MainActor
final class PersonalInfoViewModel: ObservableObject {

    @Published var profilePhotoData: Data?
    @Published var photoSelection: PhotosPickerItem? {
        didSet { loadPhoto() }
    }
    @Published var firstName: String
    @Published var lastName: String
    @Published var dateOfBirth: Date?
    @Published var nationalId: String
    @Published var gender: Gender?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let coordinator: ProfileSetupCoordinator
    private let updatePersonalInfoUseCase: UpdatePersonalInfoUseCaseProtocol

    init(
        coordinator: ProfileSetupCoordinator,
        updatePersonalInfoUseCase: UpdatePersonalInfoUseCaseProtocol
    ) {
        self.coordinator = coordinator
        self.updatePersonalInfoUseCase = updatePersonalInfoUseCase
        
        let info = coordinator.data.personalInfo
        self.profilePhotoData = info.profilePhotoData
        self.firstName = info.firstName
        self.lastName = info.lastName
        self.dateOfBirth = info.dateOfBirth
        self.nationalId = info.nationalId
        self.gender = info.gender
    }

    var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        dateOfBirth != nil &&
        !nationalId.trimmingCharacters(in: .whitespaces).isEmpty &&
        gender != nil
    }

    func continueTapped() {
        guard isValid else {
            errorMessage = "Please fill in all required fields."
            return
        }
        errorMessage = nil
        isLoading = true
        
        let info = PersonalInfo(
            profilePhotoData: profilePhotoData,
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            dateOfBirth: dateOfBirth,
            nationalId: nationalId.trimmingCharacters(in: .whitespaces),
            gender: gender
        )
        
        Task {
            do {
                try await updatePersonalInfoUseCase.execute(info: info)
                
                await MainActor.run {
                    self.isLoading = false
                    self.coordinator.save(personalInfo: info)
                    self.coordinator.next()
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Failed to update profile: \(error.localizedDescription)"
                }
            }
        }
    }

    private func loadPhoto() {
        guard let photoSelection else { return }
        Task {
            if let data = try? await photoSelection.loadTransferable(type: Data.self) {
                self.profilePhotoData = data
            }
        }
    }
}