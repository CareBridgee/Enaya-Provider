//
//  CancelOfferView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI

struct CancelOfferView: View {
    @ObservedObject var coordinator: OfferCoordinator
    @StateObject var viewModel: CancelOfferViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.s16) {
                VStack(alignment: .leading, spacing: Spacing.s8) {
                    Text("Cancel \(viewModel.serviceNameDisplay) Trip?")
                        .carelyText(style: .heading3, weight: .bold)
                        .foregroundColor(.primaryFont)

                    Text("Canceling a confirmed visit can impact patient care. We want to understand.")
                        .carelyText(style: .bodySmall, weight: .regular)
                        .foregroundColor(.secondaryFont)
                }

                if let error = viewModel.errorMessage {
                    AlertBanner(style: .error, message: error)
                } else {
                    AlertBanner(
                        style: .error,
                        message: "Frequent or late cancellations may result in cancellation fees and impact your rating, as confirmed on your current Nurse Partner Policy."
                    )
                }

                OfferSectionLabel(title: "Reason for Cancellation")

                VStack(spacing: Spacing.s8) {
                    ForEach(CancellationReason.allCases) { reason in
                        CancellationReasonRow(
                            title: reason.title,
                            isSelected: viewModel.selectedReason == reason,
                            onSelect: { viewModel.selectedReason = reason }
                        )
                    }
                }

                VStack(alignment: .leading, spacing: Spacing.s8) {
                    Text("Detailed Explanation:")
                        .carelyText(style: .bodySmall, weight: .medium)
                        .foregroundColor(.primaryFont)

                    CustomTextAreaView(placeholder: "Enter your detailed reason here...", text: $viewModel.detailText, minHeight: 80)
                }

                HStack(spacing: Spacing.s12) {
                    SecondaryButton(title: "Cancel", action: viewModel.dismissTapped)
                    PrimaryButton(
                        title: "Confirm",
                        isLoading: viewModel.isSubmitting,
                        isEnabled: viewModel.isConfirmEnabled,
                        action: viewModel.confirmTapped
                    )
                }
            }
            .padding(Spacing.s20)
        }
        .background(Color.backGround.ignoresSafeArea())
    }
}
