//
//  OfferMapAddressCard.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI
import MapKit

struct OfferMapAddressCard: View {
    let address: OfferAddress
    let onOpenInMaps: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.brandPrimary)
                Text(address.fullText)
                    .carelyText(style: .bodySmall, weight: .medium)
                    .foregroundColor(.primaryFont)
                Spacer(minLength: .zero)
            }

            Image("map-image")
                .resizable()
                .scaledToFill()
                .frame(height: 140)
                .clipShape(RoundedRectangle.carely(Radius.r16))

            Button(action: onOpenInMaps) {
                HStack(spacing: Spacing.s4) {
                    Image(systemName: "arrow.up.forward.app")
                    Text("Open in Maps")
                }
                .carelyText(style: .bodySmall, weight: .semiBold)
                .foregroundColor(.brandPrimary)
            }
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
}