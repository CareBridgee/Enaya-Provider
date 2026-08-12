//
//  OfferPatientCard.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI

struct OfferPatientCard: View {
    let name: String
    let ageText: String?
    let caption: String
    let captionValue: String
    let imageUrl: String?
    let onCall: (() -> Void)?
    let onMessage: (() -> Void)?

    var body: some View {
        HStack(spacing: Spacing.s12) {
            AsyncImage(url: URL(string: imageUrl?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")) { phase in
                switch phase {
                case .empty:
                    if (imageUrl ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        fallbackImage
                    } else {
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    fallbackImage
                @unknown default:
                    fallbackImage
                }
            }
            .frame(width: Spacing.s48, height: Spacing.s48)
            .background(Color.surfaceVariant)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text(name)
                    .carelyText(style: .bodyLarge, weight: .semiBold)
                    .foregroundColor(.primaryFont)

                if let age = ageText {
                    Text("\(caption) • Age \(age)")
                        .carelyText(style: .bodySmall, weight: .regular)
                        .foregroundColor(.secondaryFont)
                } else {
                    Text("\(caption)\n\(captionValue)")
                        .carelyText(style: .bodySmall, weight: .regular)
                        .foregroundColor(.secondaryFont)
                }
            }

            Spacer(minLength: .zero)

            HStack(spacing: Spacing.s8) {
                if let onCall { iconButton("phone", action: onCall) }
                if let onMessage { iconButton("message", action: onMessage) }
            }
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }

    private var fallbackImage: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.hint)
    }

    private func iconButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            RoundedRectangle.carely(Radius.r8)
                .fill(Color.surfaceVariant)
                .frame(width: 40, height: 40)
                .overlay(Image(systemName: icon).font(.system(size: 16, weight: .medium)).foregroundColor(.brandPrimary))
        }
    }
}
