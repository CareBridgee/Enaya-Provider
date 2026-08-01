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
                    subtitle: "Upload a clear scan of your Government issued Front Identity Card or Passport.",
                    document: $viewModel.nationalIdForntDocument
                )
                
                DocumentUploadCard(
                    title: "National Back ID",
                    subtitle: "Upload a clear scan of your Government issued Back Identity Card or Passport.",
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
                
                CarelyTextField(
                    label: "License Number",
                    isRequired: true,
                    placeholder: "e.g. 123456789",
                    text: $viewModel.licenseNumber
                )

                if let errorMessage = viewModel.errorMessage {
                    AlertBanner(style: .error, message: errorMessage)
                }
                
                // MARK: - Agreement Note & Unpinned Button
                VStack(spacing: Spacing.s16) {
                    Text("By continuing, you agree that these documents are authentic and valid. Providing false information may lead to account suspension.")
                        .carelyText(style: .caption)
                        .foregroundColor(.secondaryFont)
                        .multilineTextAlignment(.center)
                        .padding(.top, Spacing.s8)
                        .padding(.horizontal, Spacing.s8)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .brandPrimary))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.s16)
                    } else {
                        PrimaryButton(
                            title: "Continue to Step 3",
                            icon: "arrow.right",
                            iconPosition: .trailing,
                            isFullWidth: true,
                            action: viewModel.continueTapped
                        )
                    }
                }
                .padding(.top, Spacing.s8)
            }
            .padding(.horizontal, Spacing.s16)
            .padding(.top, Spacing.s16)
            .padding(.bottom, Spacing.s32)
        }
        .background(Color.backGround.ignoresSafeArea())
    }
}
