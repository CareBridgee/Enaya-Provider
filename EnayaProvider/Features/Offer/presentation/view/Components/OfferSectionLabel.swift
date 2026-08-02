//
//  OfferSectionLabel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI

struct OfferSectionLabel: View {
    let title: String
    var trailingTitle: String? = nil
    var onTrailingTapped: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title.uppercased())
                .carelyText(style: .caption, weight: .bold)
                .foregroundColor(.secondaryFont)

            Spacer()

            if let trailingTitle {
                Button(action: { onTrailingTapped?() }) {
                    Text(trailingTitle)
                        .carelyText(style: .caption, weight: .semiBold)
                        .foregroundColor(.brandPrimary)
                }
            }
        }
    }
}