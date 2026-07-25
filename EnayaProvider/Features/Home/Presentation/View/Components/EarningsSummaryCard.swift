//
//  EarningsSummaryCard.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import SwiftUI

struct EarningsSummaryCard: View {
    let amountText: String
    let changeText: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text("TODAY'S EARNINGS")
                .carelyText(style: .caption, weight: .semiBold)
                .foregroundColor(.onPrimary.opacity(0.85))

            Text(amountText)
                .carelyText(style: .heading1, weight: .bold)
                .foregroundColor(.onPrimary)

            HStack(spacing: Spacing.s4) {
                Image(systemName: "arrow.up.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: IconSize.s12, height: IconSize.s12)
                Text(changeText)
                    .carelyText(style: .caption, weight: .semiBold)
            }
            .foregroundColor(.onPrimary)
            .padding(.horizontal, Spacing.s8)
            .padding(.vertical, Spacing.s4)
            .background(Color.onPrimary.opacity(0.15))
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.s16)
        .background(Color.brandPrimary)
        .clipShape(RoundedRectangle.trueFit(Radius.r16))
    }
}