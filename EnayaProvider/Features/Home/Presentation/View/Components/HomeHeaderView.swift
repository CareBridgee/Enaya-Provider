//
//  HomeHeaderView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import SwiftUI

struct HomeHeaderView: View {
    let providerName: String
    let profileImageUrl: String?
    let greeting: String

    var body: some View {
        HStack(spacing: Spacing.s12) {
            avatar

            VStack(alignment: .leading, spacing: Spacing.s2) {
                Text(providerName)
                    .carelyText(style: .heading2, weight: .bold)
                    .foregroundColor(.brandPrimary)

                Text(greeting)
                    .carelyText(style: .bodySmall, weight: .regular)
                    .foregroundColor(.secondaryFont)
            }

            Spacer()
        }
        .padding(.top, Spacing.s16)
    }

    @ViewBuilder
    private var avatar: some View {
        if let urlString = profileImageUrl, let url = URL(string: urlString), !urlString.isEmpty {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    placeholderIcon
                }
            }
            .frame(width: Spacing.s48, height: Spacing.s48)
            .background(Color.surfaceVariant)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.brandPrimary, lineWidth: 2))
        } else {
            placeholderIcon
                .frame(width: Spacing.s48, height: Spacing.s48)
                .background(Color.surfaceVariant)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.brandPrimary, lineWidth: 2))
        }
    }

    private var placeholderIcon: some View {
        Image(systemName: "person.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.hint)
            .padding(12)
    }
}
