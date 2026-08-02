//
//  OfferStatChip.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI

struct OfferStatChip: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: Spacing.s4) {
            Circle()
                .fill(Color.mintSurface)
                .frame(width: Spacing.s32, height: Spacing.s32)
                .overlay(Image(systemName: icon).font(.system(size: 14)).foregroundColor(.brandPrimary))

            Text(value)
                .carelyText(style: .bodySmall, weight: .semiBold)
                .foregroundColor(.primaryFont)

            Text(title)
                .carelyText(style: .caption, weight: .regular)
                .foregroundColor(.secondaryFont)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.s12)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
}