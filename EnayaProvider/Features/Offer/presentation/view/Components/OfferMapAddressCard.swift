//
//  OfferMapAddressCard.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI

struct OfferMapAddressCard: View {
    let addressLine: String
    let addressDetail: String
    let onOpenInMaps: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            HStack(alignment: .top, spacing: Spacing.s8) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.brandPrimary)
                    .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: Spacing.s4) {
                    Text(addressLine)
                        .carelyText(style: .bodyLarge, weight: .medium)
                        .foregroundColor(.primaryFont)
                    Text(addressDetail)
                        .carelyText(style: .bodySmall, weight: .regular)
                        .foregroundColor(.secondaryFont)
                }
                Spacer(minLength: .zero)
            }

            ZStack(alignment: .bottomTrailing) {
                Image("map-image") // Your map asset
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140)
                    .clipShape(RoundedRectangle.carely(Radius.r12))
                    .clipped()

                Button(action: onOpenInMaps) {
                    HStack(spacing: Spacing.s8) {
                        Image(systemName: "arrow.up.forward.app")
                        Text("Open in Maps")
                    }
                    .carelyText(style: .bodySmall, weight: .semiBold)
                    .foregroundColor(.brandPrimary)
                    .padding(.horizontal, Spacing.s16)
                    .padding(.vertical, Spacing.s8)
                    .background(Color.surface)
                    .clipShape(RoundedRectangle.carely(Radius.r24))
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                }
                .padding(Spacing.s12)
            }
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
}
