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
    @Published var errorMessage: String?

    private let coordinator: ProfileSetupCoordinator

    init(coordinator: ProfileSetupCoordinator) {
        self.coordinator = coordinator
        let info = coordinator.data.professionalInfo
        self.nationalIdForntDocument = info.nationalIdFront
        self.nationalIdBackDocument = info.nationalIdBack
        self.nursingLicenseDocument = info.nursingLicenseDocument
        self.professionalCertificateDocument = info.professionalCertificateDocument
        self.yearsOfExperience = info.yearsOfExperience
        self.primarySpecialty = info.primarySpecialty
    }

    var validationError: String? {
        if nationalIdForntDocument == nil { return "National Front ID document is required." }
        if nationalIdBackDocument == nil { return "National Back ID document is required." }
        if nursingLicenseDocument == nil { return "Nursing License document is required." }
        if professionalCertificateDocument == nil { return "Professional Certificate document is required." }
        if yearsOfExperience == nil { return "Years of experience is required." }
        if primarySpecialty == nil { return "Primary specialty is required." }
        return nil
    }

    func backTapped() {
        persist()
        coordinator.previous()
    }

    func continueTapped() {
        if let error = validationError {
            errorMessage = error
            return
        }
        
        errorMessage = nil
        persist()
        coordinator.next()
    }

    private func persist() {
        coordinator.save(
            professionalInfo: ProfessionalInfo(
                nationalIdBack: nationalIdBackDocument,
                nationalIdFront: nationalIdForntDocument,
                nursingLicenseDocument: nursingLicenseDocument,
                professionalCertificateDocument: professionalCertificateDocument,
                yearsOfExperience: yearsOfExperience,
                primarySpecialty: primarySpecialty
            )
        )
    }
}
