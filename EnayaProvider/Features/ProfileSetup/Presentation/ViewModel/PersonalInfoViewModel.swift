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
    @Published var licenseNumber: String
    @Published var gender: Gender?
    @Published var errorMessage: String?

    private let coordinator: ProfileSetupCoordinator

    init(coordinator: ProfileSetupCoordinator) {
        self.coordinator = coordinator
        let info = coordinator.data.personalInfo
        self.profilePhotoData = info.profilePhotoData
        self.firstName = info.firstName
        self.lastName = info.lastName
        self.dateOfBirth = info.dateOfBirth
        self.nationalId = info.nationalId
        self.licenseNumber = info.licenseNumber
        self.gender = info.gender
    }

    var validationError: String? {
        if profilePhotoData == nil { return "Please upload a profile photo." }
        
        if firstName.trimmingCharacters(in: .whitespaces).isEmpty { return "First Name is required." }
        if lastName.trimmingCharacters(in: .whitespaces).isEmpty { return "Last Name is required." }
        
        // 21+ Age Validation
        guard let dob = dateOfBirth else { return "Date of Birth is required." }
        let ageComponents = Calendar.current.dateComponents([.year], from: dob, to: Date())
        if let age = ageComponents.year, age < 21 {
            return "You must be at least 21 years old to register."
        }
        
        let nid = nationalId.trimmingCharacters(in: .whitespaces)
        if nid.isEmpty { return "National ID is required." }
        if nid.count != 14 || !nid.allSatisfy({ $0.isNumber }) {
            return "National ID must be exactly 14 numeric digits."
        }
        
        let lic = licenseNumber.trimmingCharacters(in: .whitespaces)
        if lic.isEmpty { return "License Number is required." }
        if lic.count < 4 { return "Please enter a valid License Number." }
        
        if gender == nil { return "Gender Identity is required." }
        
        return nil
    }

    func continueTapped() {
        if let error = validationError {
            errorMessage = error
            return
        }
        
        errorMessage = nil
        coordinator.save(
            personalInfo: PersonalInfo(
                profilePhotoData: profilePhotoData,
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                lastName: lastName.trimmingCharacters(in: .whitespaces),
                dateOfBirth: dateOfBirth,
                nationalId: nationalId.trimmingCharacters(in: .whitespaces),
                licenseNumber: licenseNumber.trimmingCharacters(in: .whitespaces),
                gender: gender
            )
        )
        coordinator.next()
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
