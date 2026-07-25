//
//  HomeHeaderView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import SwiftUI

struct HomeHeaderView: View {
    let providerName: String
    let greeting: String

    var body: some View {
        HStack(spacing: Spacing.s12) {
            Circle()
                .fill(Color.surfaceVariant)
                .frame(width: Spacing.s48, height: Spacing.s48)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.hint)
                )

            VStack(alignment: .leading, spacing: Spacing.s2) {
                Text(providerName)
                    .carelyText(style: .heading3, weight: .bold)
                    .foregroundColor(.primaryFont)
                Text(greeting)
                    .carelyText(style: .bodySmall, weight: .regular)
                    .foregroundColor(.secondaryFont)
            }

            Spacer()

            Circle()
                .fill(Color.surfaceVariant)
                .frame(width: Spacing.s40, height: Spacing.s40)
                .overlay(
                    Image(systemName: "bell.fill")
                        .foregroundColor(.secondaryFont)
                )
        }
        .padding(.top, Spacing.s16)
    }
}