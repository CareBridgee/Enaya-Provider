//
//  ProfessionalInfoView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import SwiftUI

struct ProfessionalInfoView: View {
    @StateObject var viewModel: ProfessionalInfoViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.s16) {
                DocumentUploadCard(
                    title: "National Front ID",
                    subtitle: "Upload a clear scan of your Government issued Identity Card or Passport.",
                    document: $viewModel.nationalIdForntDocument
                )
                DocumentUploadCard(
                    title: "National Back ID",
                    subtitle: "Upload a clear scan of your Government issued Identity Card or Passport.",
                    document: $viewModel.nationalIdBackDocument
                )

                DocumentUploadCard(
                    title: "Nursing License",
                    subtitle: "Valid medical practice license issued by the national health board.",
                    document: $viewModel.nursingLicenseDocument
                )

                DocumentUploadCard(
                    title: "Professional Certificate",
                    subtitle: "Degree or specialization certificates (e.g., ICU, Pediatric Care).",
                    document: $viewModel.professionalCertificateDocument
                )

                SelectionField(
                    label: "Years of Experience",
                    placeholder: "Select experience",
                    options: ExperienceRange.allCases,
                    optionTitle: { $0.rawValue },
                    selection: $viewModel.yearsOfExperience
                )

                SelectionField(
                    label: "Primary Specialty",
                    placeholder: "Select your specialty",
                    options: NursingSpecialty.allCases,
                    optionTitle: { $0.rawValue },
                    selection: $viewModel.primarySpecialty
                )

                if let errorMessage = viewModel.errorMessage {
                    AlertBanner(style: .error, message: errorMessage)
                }
            }
            .padding(.horizontal, Spacing.s16)
            .padding(.top, Spacing.s16)
            .padding(.bottom, Spacing.s16)
        }
        .safeAreaInset(edge: .bottom) {
            ProfileContinueFooter(title: "Continue", onContinue: viewModel.continueTapped)
        }
        .background(Color.backGround.ignoresSafeArea())
    }
}
