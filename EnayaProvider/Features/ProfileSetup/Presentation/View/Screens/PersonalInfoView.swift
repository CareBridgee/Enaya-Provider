import SwiftUI
import PhotosUI

struct PersonalInfoView: View {
    @StateObject var viewModel: PersonalInfoViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.s20) {
                Text("Personal Information")
                    .carelyText(style: .heading3, weight: .semiBold)
                    .foregroundColor(.primaryFont)
                    .frame(maxWidth: .infinity, alignment: .leading)

                photoPicker

                CarelyTextField(label: "First Name", isRequired: true, placeholder: "e.g. Sarah", text: $viewModel.firstName)
                CarelyTextField(label: "Last Name", isRequired: true, placeholder: "e.g. Jenkins", text: $viewModel.lastName)

                DateOfBirthField(date: $viewModel.dateOfBirth)

                CarelyTextField(label: "National ID", isRequired: true, placeholder: "0000000000000", text: $viewModel.nationalId, keyboardType: .numberPad)

                SelectionField(
                    label: "Gender Identity",
                    placeholder: "Select Gender",
                    options: Gender.allCases,
                    optionTitle: { $0.rawValue },
                    selection: $viewModel.gender
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
            ProfileContinueFooter(title: "Continue to Step 2", onContinue: viewModel.continueTapped)
        }
        .background(Color.backGround.ignoresSafeArea())
    }

    private var photoPicker: some View {
        PhotosPicker(selection: $viewModel.photoSelection, matching: .images) {
            ZStack {
                Circle()
                    .fill(Color.surfaceVariant)
                    .frame(width: Spacing.s64 + Spacing.s16, height: Spacing.s64 + Spacing.s16)

                if let data = viewModel.profilePhotoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: Spacing.s64 + Spacing.s16, height: Spacing.s64 + Spacing.s16)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.hint)
                }
            }
        }
    }
}