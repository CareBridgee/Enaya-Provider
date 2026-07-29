//
//  DocumentRejectedView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import SwiftUI

struct DocumentRejectedView: View {
    @StateObject var viewModel: DocumentRejectedViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.s20) {
                ApplicationStatusHeader()

                StatusHeroBadge(systemIcon: "exclamationmark.triangle.fill", tint: .error)
                    .padding(.top, Spacing.s16)

                VStack(alignment: .leading, spacing: Spacing.s8) {
                    Text("Action Required")
                        .carelyText(style: .heading3, weight: .semiBold)
                        .foregroundColor(.error)

                    Text("Your \(viewModel.rejection.documentName) was rejected because \(viewModel.rejection.reason).")
                        .carelyText(style: .bodyRegular, weight: .regular)
                        .foregroundColor(.primaryFont)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: Spacing.s12) {
                    ForEach(viewModel.rejection.tips) { tip in
                        HStack(spacing: Spacing.s12) {
                            Image(systemName: tip.icon)
                                .foregroundColor(.brandPrimary)
                                .frame(width: IconSize.s24)

                            VStack(alignment: .leading, spacing: Spacing.s2) {
                                Text(tip.title)
                                    .carelyText(style: .bodyRegular, weight: .semiBold)
                                    .foregroundColor(.primaryFont)
                                Text(tip.detail)
                                    .carelyText(style: .caption, weight: .regular)
                                    .foregroundColor(.secondaryFont)
                            }

                            Spacer(minLength: .zero)
                        }
                        .padding(Spacing.s12)
                        .background(Color.surface)
                        .clipShape(RoundedRectangle.carely(Radius.r12))
                    }
                }

                PrimaryButton(title: "Upload Again", icon: "arrow.up.circle.fill", action: viewModel.uploadAgainTapped)
                SecondaryButton(title: "Contact Support", action: viewModel.contactSupportTapped)

                Text("Need help? Visit our Help Center for a step-by-step guide on document verification.")
                    .carelyText(style: .caption, weight: .regular)
                    .foregroundColor(.hint)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Spacing.s16)
            .padding(.bottom, Spacing.s16)
        }
        .background(Color.backGround.ignoresSafeArea())
    }
}
