//
//  StatCard.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    var valueTrailingIcon: String? = nil
    var valueTrailingIconColor: Color = .brandPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text(title)
                .carelyText(style: .caption, weight: .regular)
                .foregroundColor(.secondaryFont)

            HStack(spacing: Spacing.s4) {
                Text(value)
                    .carelyText(style: .bodyRegular, weight: .semiBold)
                    .foregroundColor(.primaryFont)

                if let valueTrailingIcon {
                    Image(systemName: valueTrailingIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: IconSize.s16, height: IconSize.s16)
                        .foregroundColor(valueTrailingIconColor)
                }
            }
        }
        .padding(Spacing.s16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
}
