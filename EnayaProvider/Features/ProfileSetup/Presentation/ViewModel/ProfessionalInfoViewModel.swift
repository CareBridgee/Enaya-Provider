//
//  ProfessionalInfoViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import Foundation

@MainActor
final class ProfessionalInfoViewModel: ObservableObject {

    @Published var nationalIdForntDocument: UploadedDocument?
    @Published var nationalIdBackDocument: UploadedDocument?

    @Published var nursingLicenseDocument: UploadedDocument?
    @Published var professionalCertificateDocument: UploadedDocument?
    @Published var yearsOfExperience: ExperienceRange?
    @Published var primarySpecialty: NursingSpecialty?
    @Published var licenseNumber: String = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let coordinator: ProfileSetupCoordinator
    private let registerNurseUseCase: RegisterNurseUseCaseProtocol

    init(
        coordinator: ProfileSetupCoordinator,
        registerNurseUseCase: RegisterNurseUseCaseProtocol
    ) {
        self.coordinator = coordinator
        self.registerNurseUseCase = registerNurseUseCase
        
        let info = coordinator.data.professionalInfo
        self.nationalIdForntDocument = info.nationalIdDocument
        self.nationalIdBackDocument = info.nationalIdBackDocument
        self.nursingLicenseDocument = info.nursingLicenseDocument
        self.professionalCertificateDocument = info.professionalCertificateDocument
        self.yearsOfExperience = info.yearsOfExperience
        self.primarySpecialty = info.primarySpecialty
        self.licenseNumber = info.licenseNumber ?? ""
    }

    var isValid: Bool {
        nationalIdForntDocument != nil && nationalIdBackDocument != nil && nursingLicenseDocument != nil && professionalCertificateDocument != nil &&
        yearsOfExperience != nil && primarySpecialty != nil && !licenseNumber.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func backTapped() {
        persist()
        coordinator.previous()
    }

    func continueTapped() {
        guard isValid else {
            errorMessage = "Please complete all required fields and upload all documents."
            return
        }
        errorMessage = nil
        isLoading = true
        persist()
        
        let info = ProfessionalInfo(
            nationalIdDocument: nationalIdForntDocument,
            nationalIdBackDocument: nationalIdBackDocument,
            nursingLicenseDocument: nursingLicenseDocument,
            professionalCertificateDocument: professionalCertificateDocument,
            yearsOfExperience: yearsOfExperience,
            primarySpecialty: primarySpecialty,
            licenseNumber: licenseNumber,
            bio: nil
        )
        
        Task {
            do {
                try await registerNurseUseCase.execute(info: info, personalInfo: coordinator.data.personalInfo)
                
                await MainActor.run {
                    self.isLoading = false
                    self.coordinator.next()
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Failed to register nurse: \(error.localizedDescription)"
                }
            }
        }
    }

    private func persist() {
        coordinator.save(
            professionalInfo: ProfessionalInfo(
                nationalIdDocument: nationalIdForntDocument,
                nationalIdBackDocument: nationalIdBackDocument,
                nursingLicenseDocument: nursingLicenseDocument,
                professionalCertificateDocument: professionalCertificateDocument,
                yearsOfExperience: yearsOfExperience,
                primarySpecialty: primarySpecialty,
                licenseNumber: licenseNumber,
                bio: nil
            )
        )
    }
}
