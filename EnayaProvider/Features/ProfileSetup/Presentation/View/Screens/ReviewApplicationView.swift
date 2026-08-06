//
//  ReviewApplicationView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import SwiftUI

struct ReviewApplicationView: View {
    @StateObject var viewModel: ReviewApplicationViewModel
    @State private var isCertified: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ReviewCustomHeader()
                .padding(.horizontal, Spacing.s16)
                .padding(.bottom, Spacing.s16)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.s20) {
                    VStack(alignment: .leading, spacing: Spacing.s8) {
                        Text("Review Your Application")
                            .carelyText(style: .heading2, weight: .bold)
                            .foregroundColor(.primaryFont)

                        Text("Please take a moment to ensure all details are correct. You can edit any section before final submission.")
                            .carelyText(style: .bodyRegular)
                            .foregroundColor(.secondaryFont)
                            .lineSpacing(4)
                    }

                    ReviewProgressIndicator()

                    ReviewPersonalInfoCard(viewModel: viewModel)
                    ReviewProfessionalInfoCard(viewModel: viewModel)
                    ReviewServicesCard(viewModel: viewModel)
                    ReviewDocumentsCard(viewModel: viewModel)
                    
                    ReviewPrivacyBanner()

                    if let errorMessage = viewModel.errorMessage {
                        AlertBanner(style: .error, message: errorMessage)
                    }
                }
                .padding(.horizontal, Spacing.s16)
                .padding(.bottom, Spacing.s24)
            }
        }
        .background(Color.backGround.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            ReviewSubmitFooter(
                isCertified: $isCertified,
                isSubmitting: viewModel.isSubmitting,
                onSubmit: viewModel.submitTapped
            )
        }
    }
}
#Preview {
    let coordinator = ProfileSetupCoordinator(data: ProfileSetupData())
    let container = DIContainer()
    ReviewApplicationView(
        viewModel: container.makeReviewApplicationViewModel(coordinator: coordinator, onSubmitted: {})
    )
}
