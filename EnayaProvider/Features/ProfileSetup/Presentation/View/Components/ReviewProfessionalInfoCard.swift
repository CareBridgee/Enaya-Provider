import SwiftUI

struct ReviewProfessionalInfoCard: View {
    @ObservedObject var viewModel: ReviewApplicationViewModel

    var body: some View {
        ReviewSectionCard(
            title: "Professional Info",
            icon: "briefcase",
            onEdit: viewModel.editProfessionalInfoTapped
        ) {
            VStack(alignment: .leading, spacing: Spacing.s16) {
                HStack(spacing: Spacing.s12) {
                    Image(systemName: "person.text.rectangle")
                        .foregroundColor(.brandPrimary)
                        .font(.system(size: IconSize.s24))
                    
                    VStack(alignment: .leading, spacing: Spacing.s2) {
                        Text("National ID / License")
                            .carelyText(style: .caption)
                            .foregroundColor(.secondaryFont)
                        Text(viewModel.data.personalInfo.nationalId.isEmpty ? "—" : viewModel.data.personalInfo.nationalId)
                            .carelyText(style: .bodyRegular, weight: .medium)
                            .foregroundColor(.primaryFont)
                    }
                    Spacer()
                }
                .padding(Spacing.s12)
                .background(Color.surfaceVariant)
                .clipShape(RoundedRectangle.carely(Radius.r12))

                ReviewInfoRow(label: "Experience", value: viewModel.data.professionalInfo.yearsOfExperience?.rawValue ?? "—")
                ReviewInfoRow(label: "Primary Specialty", value: viewModel.data.professionalInfo.primarySpecialty?.rawValue ?? "—")
            }
        }
    }
}