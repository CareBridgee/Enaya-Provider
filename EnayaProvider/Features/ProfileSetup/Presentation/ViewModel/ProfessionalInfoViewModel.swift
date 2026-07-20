import Foundation

@MainActor
final class ProfessionalInfoViewModel: ObservableObject {

    @Published var nationalIdDocument: UploadedDocument?
    @Published var nursingLicenseDocument: UploadedDocument?
    @Published var professionalCertificateDocument: UploadedDocument?
    @Published var yearsOfExperience: ExperienceRange?
    @Published var primarySpecialty: NursingSpecialty?
    @Published var errorMessage: String?

    private let coordinator: ProfileSetupCoordinator

    init(coordinator: ProfileSetupCoordinator) {
        self.coordinator = coordinator
        let info = coordinator.data.professionalInfo
        self.nationalIdDocument = info.nationalIdDocument
        self.nursingLicenseDocument = info.nursingLicenseDocument
        self.professionalCertificateDocument = info.professionalCertificateDocument
        self.yearsOfExperience = info.yearsOfExperience
        self.primarySpecialty = info.primarySpecialty
    }

    var isValid: Bool {
        nationalIdDocument != nil && nursingLicenseDocument != nil &&
        yearsOfExperience != nil && primarySpecialty != nil
    }

    func backTapped() {
        persist()
        coordinator.previous()
    }

    func continueTapped() {
        guard isValid else {
            errorMessage = "Please upload your National ID, Nursing License, and complete the fields above."
            return
        }
        errorMessage = nil
        persist()
        coordinator.next()
    }

    private func persist() {
        coordinator.save(
            professionalInfo: ProfessionalInfo(
                nationalIdDocument: nationalIdDocument,
                nursingLicenseDocument: nursingLicenseDocument,
                professionalCertificateDocument: professionalCertificateDocument,
                yearsOfExperience: yearsOfExperience,
                primarySpecialty: primarySpecialty
            )
        )
    }
}