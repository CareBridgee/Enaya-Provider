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
    let onCall: (() -> Void)?
    let onMessage: (() -> Void)?

    var body: some View {
        HStack(spacing: Spacing.s12) {
            Circle()
                .fill(Color.surfaceVariant)
                .frame(width: Spacing.s48, height: Spacing.s48)
                .overlay(Image(systemName: "person.fill").foregroundColor(.hint))

            VStack(alignment: .leading, spacing: Spacing.s2) {
                Text(name)
                    .carelyText(style: .bodyLarge, weight: .semiBold)
                    .foregroundColor(.primaryFont)

                Text(ageText.map { "\(caption) • \($0)" } ?? "\(caption): \(captionValue)")
                    .carelyText(style: .caption, weight: .regular)
                    .foregroundColor(.secondaryFont)
            }

            Spacer(minLength: .zero)

            if let onCall {
                iconButton("phone.fill", action: onCall)
            }
            if let onMessage {
                iconButton("message.fill", action: onMessage)
            }
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }

    private func iconButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(Color.mintSurface)
                .frame(width: Spacing.s32, height: Spacing.s32)
                .overlay(Image(systemName: icon).font(.system(size: 14)).foregroundColor(.brandPrimary))
        }
    }
}