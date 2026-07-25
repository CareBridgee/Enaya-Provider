//
//  OfflineStateView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import SwiftUI

struct OfflineStateView: View {
    let onGoOnline: () -> Void

    private let illustrationSize: CGFloat = 140
    private let badgeSize: CGFloat = 44

    var body: some View {
        VStack(spacing: Spacing.s24) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle.trueFit(Radius.r24)
                    .fill(Color.surfaceVariant)
                    .frame(width: illustrationSize, height: illustrationSize)
                    .overlay(
                        Image(systemName: "bag.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: IconSize.s32, height: IconSize.s32)
                            .foregroundColor(.hint)
                    )

                Circle()
                    .fill(Color.brandPrimary)
                    .frame(width: badgeSize, height: badgeSize)
                    .overlay(
                        Image(systemName: "stethoscope")
                            .foregroundColor(.onPrimary)
                    )
                    .shadow(color: .black.opacity(0.1), radius: Radius.r8, y: Spacing.s2)
                    .offset(x: Spacing.s8, y: Spacing.s8)
            }

            VStack(spacing: Spacing.s8) {
                Text("You are currently offline.")
                    .carelyText(style: .bodyLarge, weight: .semiBold)
                    .foregroundColor(.primaryFont)

                Text("Go online to start accepting new requests.")
                    .carelyText(style: .bodySmall, weight: .regular)
                    .foregroundColor(.secondaryFont)
                    .multilineTextAlignment(.center)
            }

            PrimaryButton(title: "Go Online", icon: "power", isFullWidth: false, action: onGoOnline)
        }
        .padding(.horizontal, Spacing.s24)
    }
}