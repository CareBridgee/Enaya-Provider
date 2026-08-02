//
//  OfferConfirmedView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI

struct OfferConfirmedView: View {
    @ObservedObject var coordinator: OfferCoordinator
    @StateObject var viewModel: OfferConfirmedViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.s20) {
                statusHero
                patientCard
                statsRow
                InfoBannerView(text: "You can cancel within 2 minutes after the visit starts. After that, a cancellation fee will apply.")

                SecondaryButton(title: "View Offer Details", icon: "doc.text", action: viewModel.openDetails)

                PrimaryButton(
                    title: viewModel.actionButtonTitle,
                    icon: "qrcode",
                    isLoading: viewModel.isProcessing,
                    action: viewModel.primaryActionTapped
                )

                if viewModel.canCancel {
                    cancelButton
                }
            }
            .padding(.horizontal, Spacing.s16)
            .padding(.top, Spacing.s16)
            .padding(.bottom, Spacing.s24)
        }
        .background(Color.backGround.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top) {
            AppHeader(title: AppConstants.appName, showBackButton: false)
                .padding(.horizontal, Spacing.s16)
                .background(Color.backGround)
        }
    }

    private var statusHero: some View {
        VStack(spacing: Spacing.s12) {
            ZStack {
                Circle().fill(Color.mintSurface).frame(width: Spacing.s64, height: Spacing.s64)
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: IconSize.s32, height: IconSize.s32)
                    .foregroundColor(.success)
            }

            Text(viewModel.titleText)
                .carelyText(style: .heading2, weight: .bold)
                .foregroundColor(.primaryFont)

            Text(viewModel.subtitleText)
                .carelyText(style: .bodyRegular, weight: .regular)
                .foregroundColor(.secondaryFont)
        }
    }

    private var patientCard: some View {
        OfferPatientCard(
            name: coordinator.offer.patient.name,
            ageText: nil,
            caption: "Estimated Arrival",
            captionValue: coordinator.offer.estimatedArrivalText,
            onCall: {},
            onMessage: {}
        )
    }

    private var statsRow: some View {
        HStack(spacing: Spacing.s12) {
            OfferStatChip(icon: "location.fill", title: "Distance", value: coordinator.offer.distanceText)
            OfferStatChip(icon: "briefcase.fill", title: "Service", value: coordinator.offer.serviceName)
        }
    }

    private var cancelButton: some View {
        Button(action: viewModel.presentCancelSheet) {
            Text("Cancel")
                .carelyText(style: .button, weight: .semiBold)
                .foregroundColor(.onErrorContainer)
                .frame(maxWidth: .infinity)
                .frame(height: CarelyButtonSize.medium.height)
                .background(Color.errorContainer)
                .clipShape(RoundedRectangle.carely(Radius.r12))
        }
    }
}