//
//  AccountVerifiedView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import SwiftUI

struct AccountVerifiedView: View {
    @StateObject var viewModel: AccountVerifiedViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.s20) {
                ApplicationStatusHeader()

                StatusHeroBadge(systemIcon: "checkmark.circle.fill", tint: .success)
                    .padding(.top, Spacing.s16)

                Text("Verified")
                    .carelyText(style: .caption, weight: .semiBold)
                    .foregroundColor(.onSuccessContainer)
                    .padding(.horizontal, Spacing.s12)
                    .padding(.vertical, Spacing.s4)
                    .background(Color.successContainer)
                    .clipShape(Capsule())

                VStack(spacing: Spacing.s8) {
                    Text("Congratulations!")
                        .carelyText(style: .heading2, weight: .bold)
                        .foregroundColor(.primaryFont)

                    Text("Your account has been verified.")
                        .carelyText(style: .bodyRegular, weight: .semiBold)
                        .foregroundColor(.success)

                    Text("You are now part of the Enaya network. Start accepting jobs to grow your career and provide care to those who need it most.")
                        .carelyText(style: .bodySmall, weight: .regular)
                        .foregroundColor(.secondaryFont)
                        .multilineTextAlignment(.center)
                }

                PrimaryButton(
                    title: "Start your journey",
                    icon: "arrow.right",
                    iconPosition: .trailing,
                    action: viewModel.startJourneyTapped
                )

                Button(action: viewModel.reviewGuidelinesTapped) {
                    Text("Review Community Guidelines")
                        .carelyText(style: .bodySmall, weight: .medium)
                        .foregroundColor(.brandPrimary)
                }

                HStack(spacing: Spacing.s12) {
                    statCard(icon: "briefcase.fill", title: "Available Jobs", value: "\(viewModel.availableJobsCount) Near You")
                    statCard(icon: "star.fill", title: "Network Perks", value: "\(viewModel.networkRewardsCount) Rewards")
                }
            }
            .padding(.horizontal, Spacing.s16)
            .padding(.bottom, Spacing.s16)
        }
        .background(Color.backGround.ignoresSafeArea())
    }

    private func statCard(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Image(systemName: icon)
                .foregroundColor(.brandPrimary)
            Text(title)
                .carelyText(style: .caption, weight: .regular)
                .foregroundColor(.secondaryFont)
            Text(value)
                .carelyText(style: .bodyRegular, weight: .semiBold)
                .foregroundColor(.primaryFont)
        }
        .padding(Spacing.s16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
}
