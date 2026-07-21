//
//  UnderReviewView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import SwiftUI

struct UnderReviewView: View {
    @StateObject var viewModel: UnderReviewViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.s24) {
                ApplicationStatusHeader()

                StatusHeroBadge(
                    systemIcon: "checkmark.shield.fill",
                    tint: .brandPrimary,
                    topAccessoryIcon: "briefcase.fill",
                    bottomAccessoryIcon: "bubble.left.fill"
                )
                .padding(.top, Spacing.s16)

                VStack(spacing: Spacing.s8) {
                    Text("Application Under Review")
                        .carelyText(style: .heading3, weight: .semiBold)
                        .foregroundColor(.primaryFont)

                    Text("We are currently verifying your credentials to ensure the highest standard of care. This usually takes less than 24 hours.")
                        .carelyText(style: .bodySmall, weight: .regular)
                        .foregroundColor(.secondaryFont)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: Spacing.s4) {
                    ApplicationChecklistRow(icon: "doc.text.fill", title: "Application Received", state: .completed)
                    Divider()
                    ApplicationChecklistRow(icon: "shield.fill", title: "Background Check", state: .inProgress)
                    Divider()
                    ApplicationChecklistRow(icon: "checkmark.seal.fill", title: "Final Approval", state: .pending)
                }
                .padding(Spacing.s16)
                .background(Color.surface)
                .clipShape(RoundedRectangle.trueFit(Radius.r16))

                VStack(spacing: Spacing.s12) {
                    SecondaryButton(
                        title: "Contact Support",
                        icon: "bubble.left.and.bubble.right.fill",
                        action: viewModel.contactSupportTapped
                    )

                    Button(action: viewModel.backToLoginTapped) {
                        Text("Back to Login")
                            .carelyText(style: .bodySmall, weight: .medium)
                            .foregroundColor(.secondaryFont)
                            .underline()
                    }
                }
            }
            .padding(.horizontal, Spacing.s16)
            .padding(.bottom, Spacing.s16)
        }
        .background(Color.backGround.ignoresSafeArea())
    }
}