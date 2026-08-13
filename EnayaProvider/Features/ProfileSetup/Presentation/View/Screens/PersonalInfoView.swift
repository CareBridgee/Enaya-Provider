//
//  PersonalInfoView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import SwiftUI
import PhotosUI

struct PersonalInfoView: View {
    @StateObject var viewModel: PersonalInfoViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack(spacing: 0) {
                VStack(spacing: Spacing.s20) {
                    
                    VStack(alignment: .leading, spacing: Spacing.s8) {
                        Text("Personal Information")
                            .carelyText(style: .heading3, weight: .semiBold)
                            .foregroundColor(.primaryFont)

                        Text("Let's start with the basics. Please provide your legal details for verification.")
                            .carelyText(style: .bodyRegular)
                            .foregroundColor(.secondaryFont)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Spacing.s16)

                    photoPicker

                    CarelyTextField(
                        label: "First Name",
                        isRequired: false,
                        placeholder: "e.g. Sarah",
                        text: $viewModel.firstName
                    )

                    CarelyTextField(
                        label: "Last Name",
                        isRequired: false,
                        placeholder: "e.g. Jenkins",
                        text: $viewModel.lastName
                    )

                    DateOfBirthField(date: $viewModel.dateOfBirth)

                    CarelyTextField(
                        label: "National ID",
                        isRequired: false,
                        placeholder: "0000000000000",
                        text: $viewModel.nationalId,
                        keyboardType: .numberPad
                    )

                    CarelyTextField(
                        label: "License Number",
                        isRequired: false,
                        placeholder: "Enter License Number",
                        text: $viewModel.licenseNumber
                    )

                    SelectionField(
                        label: "Gender Identity",
                        placeholder: "Select Gender",
                        leadingIcon: "person",
                        options: Gender.allCases,
                        optionTitle: { $0.rawValue },
                        selection: $viewModel.gender
                    )

                    if let errorMessage = viewModel.errorMessage {
                        AlertBanner(style: .error, message: errorMessage)
                    }
                    
                    VStack(spacing: Spacing.s16) {
                        PrimaryButton(
                            title: "Continue to Step 2",
                            icon: "arrow.right",
                            iconPosition: .trailing,
                            isFullWidth: true,
                            action: viewModel.continueTapped
                        )

                        Text("Step 1 of 3: Personal Information")
                            .carelyText(style: .caption)
                            .foregroundColor(.secondaryFont)
                    }
                    .padding(.top, Spacing.s8)
                    .padding(.bottom, Spacing.s24)
                }
                .padding(.horizontal, Spacing.s16)
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, Spacing.s16)
                .padding(.top, Spacing.s16)
                hipaaBanner
                    .padding(.horizontal, Spacing.s16)
                    .padding(.top, Spacing.s16)
                    .padding(.bottom, Spacing.s32)
            }
        }
        .background(Color.backGround.ignoresSafeArea())
    }

    // MARK: - Subviews

    private var photoPicker: some View {
            let currentPhotoData = viewModel.profilePhotoData
            
            return VStack(spacing: Spacing.s12) {
                PhotosPicker(selection: $viewModel.photoSelection, matching: .images) {
                    ZStack(alignment: .bottomTrailing) {
                        ZStack {
                            Circle()
                                .fill(Color.surfaceVariant)
                                .frame(width: 96, height: 96)

                            if let data = currentPhotoData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 96, height: 96)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "camera")
                                    .font(.system(size: 28))
                                    .foregroundColor(.hint)
                            }
                        }
                        .overlay(
                            Circle()
                                .strokeBorder(Color.brandPrimary.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                        )

                        Circle()
                            .fill(Color.brandPrimary)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: -4, y: -4)
                    }
                }

                Text("Upload Profile Photo")
                    .carelyText(style: .bodySmall, weight: .bold)
                    .foregroundColor(.brandPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.s4)
        }

        private var hipaaBanner: some View {
            HStack(spacing: Spacing.s12) {
                Image(systemName: "checkmark.shield.fill")
                .foregroundColor(.brandPrimary)
                .font(.system(size: IconSize.s16))

            Text("Encrypted & HIPAA Compliant Data\nStorage")
                .carelyText(style: .caption, weight: .medium)
                .foregroundColor(.secondaryFont)
        }
        .padding(Spacing.s12)
        .background(Color.surfaceVariant)
        .clipShape(RoundedRectangle.carely(Radius.r12))
    }
}

#Preview {
    PersonalInfoView(viewModel: PersonalInfoViewModel(coordinator: ProfileSetupCoordinator(data: ProfileSetupData())))
}
