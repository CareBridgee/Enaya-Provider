//
//  ProvidedServicesView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import SwiftUI

struct ProvidedServicesView: View {
    @StateObject var viewModel: ProvidedServicesViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.s16) {
                Text("Services You Provide")
                    .carelyText(style: .heading3, weight: .semiBold)
                    .foregroundColor(.primaryFont)

                Text("Select all services you are qualified and willing to provide to patients.")
                    .carelyText(style: .bodySmall, weight: .regular)
                    .foregroundColor(.secondaryFont)

                ServiceSelectionGrid(selected: viewModel.selectedServices, onToggle: viewModel.toggle)

                InfoBannerView(
                    text: "You can update these services later from your profile settings. Ensure you have valid certifications for the selected specialized services."
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
            ProfileContinueFooter(title: "Continue to Step 4", onContinue: viewModel.continueTapped)
        }
        .background(Color.backGround.ignoresSafeArea())
    }
}