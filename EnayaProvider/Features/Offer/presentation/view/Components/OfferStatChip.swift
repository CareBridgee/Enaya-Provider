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
    var isPrimaryStyle: Bool = false

    var body: some View {
        VStack(spacing: Spacing.s12) {
            Circle()
                .fill(isPrimaryStyle ? Color.brandPrimary : Color.mintSurface)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(isPrimaryStyle ? Color.surface : Color.brandPrimary)
                        .font(.system(size: 20))
                )

            VStack(spacing: Spacing.s4) {
                Text(title)
                    .carelyText(style: .caption)
                    .foregroundColor(Color.secondaryFont)

                Text(value)
                    .carelyText(style: .bodyRegular, weight: .semiBold)
                    .foregroundColor(Color.primaryFont)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.s20)
        .background(Color.surface)
        .cornerRadius(Radius.r24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}