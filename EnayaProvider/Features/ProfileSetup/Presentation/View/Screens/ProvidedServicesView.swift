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
            VStack(alignment: .leading, spacing: Spacing.s20) {
                
                VStack(alignment: .leading, spacing: Spacing.s8) {
                    Text("Services You Provide")
                        .carelyText(style: .heading3, weight: .bold)
                        .foregroundColor(.primaryFont)

                    Text("Select all services you are qualified and willing to provide to patients.")
                        .carelyText(style: .bodyRegular)
                        .foregroundColor(.secondaryFont)
                        .lineSpacing(4)
                }
                .padding(.top, Spacing.s8)

                if viewModel.isLoading && viewModel.availableServices.isEmpty {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: Spacing.s12), GridItem(.flexible(), spacing: Spacing.s12)],
                        spacing: Spacing.s12
                    ) {
                        ForEach(0..<6, id: \.self) { _ in
                            HStack(spacing: Spacing.s8) {
                                EtmaenSkeletonCircle(size: 20)
                                EtmaenSkeletonRect(width: 80, height: 14, radius: Radius.r8)
                            }
                            .padding(.horizontal, Spacing.s16)
                            .padding(.vertical, Spacing.s12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.surface)
                            .cornerRadius(Radius.r12)
                        }
                    }
                } else {
                    ServiceSelectionGrid(
                        availableServices: viewModel.availableServices,
                        selected: viewModel.selectedServices,
                        onToggle: viewModel.toggle
                    )
                }

                InfoBannerView(
                    text: "You can update these services later from your profile settings. Ensure you have valid certifications for the selected specialized services."
                )

                if let errorMessage = viewModel.errorMessage {
                    AlertBanner(style: .error, message: errorMessage)
                }
            }
            .padding(.horizontal, Spacing.s16)
            .padding(.bottom, Spacing.s24)
        }
        .onAppear {
            viewModel.loadServices()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                PrimaryButton(
                    title: "Review Profile",
                    isFullWidth: true,
                    action: viewModel.continueTapped
                )
                .padding(.horizontal, Spacing.s16)
                .padding(.top, Spacing.s16)
                .padding(.bottom, Spacing.s16)
            }
            .background(Color.backGround)
        }
        .background(Color.backGround.ignoresSafeArea())
    }
}
