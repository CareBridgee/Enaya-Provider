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
        ZStack {
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
            .disabled(viewModel.isSubmitting)
            .blur(radius: viewModel.isSubmitting ? 3 : 0)
            
            if viewModel.isSubmitting {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.s16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .brandPrimary))
                        .scaleEffect(1.5)
                        .padding(.bottom, Spacing.s8)
                    
                    Text("Please Wait")
                        .carelyText(style: .heading3, weight: .bold)
                        .foregroundColor(.primaryFont)
                    
                    Text("We are processing your application.\nThis might take a moment.")
                        .carelyText(style: .bodyRegular, weight: .medium)
                        .foregroundColor(.secondaryFont)
                        .multilineTextAlignment(.center)
                }
                .padding(Spacing.s24)
                .background(Color.surface)
                .clipShape(RoundedRectangle.carely(Radius.r16))
                .shadow(color: Color.black.opacity(0.15), radius: 24, y: 8)
                .padding(.horizontal, Spacing.s32)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isSubmitting)
    }
}
