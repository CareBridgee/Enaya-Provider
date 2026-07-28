import SwiftUI

struct ReviewPersonalInfoCard: View {
    @ObservedObject var viewModel: ReviewApplicationViewModel

    var body: some View {
        ReviewSectionCard(
            title: "Personal Info",
            icon: "person",
            onEdit: viewModel.editPersonalInfoTapped
        ) {
            VStack(alignment: .leading, spacing: Spacing.s16) {
                ReviewInfoRow(label: "Full Name", value: "\(viewModel.data.personalInfo.firstName) \(viewModel.data.personalInfo.lastName)")
                ReviewInfoRow(label: "National ID", value: viewModel.data.personalInfo.nationalId)
                ReviewInfoRow(label: "Gender", value: viewModel.data.personalInfo.gender?.rawValue ?? "—")
            }
        }
    }
}