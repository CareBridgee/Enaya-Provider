//
//  OfferSummaryDetailGrid.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI

struct OfferSummaryDetailGrid: View {
    struct Item {
        let icon: String
        let label: String
        let value: String
    }

    let items: [Item]

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.s16) {
            ForEach(items, id: \.label) { item in
                VStack(alignment: .leading, spacing: Spacing.s4) {
                    Text(item.label.uppercased())
                        .carelyText(style: .caption, weight: .bold)
                        .foregroundColor(.secondaryFont)

                    HStack(spacing: Spacing.s4) {
                        Image(systemName: item.icon)
                            .foregroundColor(.brandPrimary)
                        Text(item.value)
                            .carelyText(style: .bodyRegular, weight: .semiBold)
                            .foregroundColor(.primaryFont)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}