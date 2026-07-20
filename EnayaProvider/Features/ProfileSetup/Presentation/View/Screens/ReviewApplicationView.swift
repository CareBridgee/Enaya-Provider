import SwiftUI

struct ReviewApplicationView: View {
    @StateObject var viewModel: ReviewApplicationViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.s16) {
                Text("Review Your Application")
                    .carelyText(style: .heading3, weight: .semiBold)
                    .foregroundColor(.primaryFont)

                Text("Please take a moment to ensure all details are correct. You can edit any section before final submission.")
                    .carelyText(style: .bodySmall, weight: .regular)
                    .foregroundColor(.secondaryFont)

                ReviewSectionCard(
                    title: "Personal Info",
                    onEdit: viewModel.editPersonalInfoTapped,
                    rows: [
                        ("Full Name", "\(viewModel.data.personalInfo.firstName) \(viewModel.data.personalInfo.lastName)"),
                        ("National ID", viewModel.data.personalInfo.nationalId),
                        ("Gender", viewModel.data.personalInfo.gender?.rawValue ?? "—")
                    ]
                )

                ReviewSectionCard(
                    title: "Professional Info",
                    onEdit: viewModel.editProfessionalInfoTapped,
                    rows: [
                        ("Experience", viewModel.data.professionalInfo.yearsOfExperience?.rawValue ?? "—"),
                        ("Primary Specialty", viewModel.data.professionalInfo.primarySpecialty?.rawValue ?? "—")
                    ]
                )

                ReviewSectionCard(
                    title: "Selected Services",
                    onEdit: viewModel.editServicesTapped,
                    rows: [
                        ("Services", viewModel.data.providedServices.selectedServices.map(\.title).joined(separator: ", "))
                    ]
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
            ProfileContinueFooter(
                title: "Submit Application",
                isLoading: viewModel.isSubmitting,
                onContinue: viewModel.submitTapped
            )
        }
        .background(Color.backGround.ignoresSafeArea())
    }
}