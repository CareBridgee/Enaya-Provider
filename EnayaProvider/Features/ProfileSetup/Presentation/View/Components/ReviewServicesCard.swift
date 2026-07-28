import SwiftUI

struct ReviewServicesCard: View {
    @ObservedObject var viewModel: ReviewApplicationViewModel

    var body: some View {
        ReviewSectionCard(
            title: "Selected Services",
            icon: "cross.case",
            onEdit: viewModel.editServicesTapped
        ) {
            let columns = [GridItem(.adaptive(minimum: 120), spacing: Spacing.s8)]
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: Spacing.s12) {
                ForEach(Array(viewModel.data.providedServices.selectedServices), id: \.self) { service in
                    Text(service.title)
                        .carelyText(style: .bodySmall, weight: .medium)
                        .foregroundColor(.brandPrimary)
                        .padding(.vertical, Spacing.s8)
                        .padding(.horizontal, Spacing.s16)
                        .background(Color.brandPrimary.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
    }
}