//
//  EditOfferPopupView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import SwiftUI

struct EditOfferPopupView: View {
    let jobRequest: JobRequest
    @Binding var proposedPriceValue: Double
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: Spacing.s24) {
            header
            serviceRow
            sliderSection
            footer
        }
        .padding(Spacing.s20)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r24))
        .shadow(color: .black.opacity(0.15), radius: Radius.r24, y: Spacing.s12)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: Spacing.s12) {
            Circle()
                .fill(Color.surfaceVariant)
                .frame(width: Spacing.s48, height: Spacing.s48)
                .overlay(Image(systemName: "person.fill").foregroundColor(.hint))

            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text(jobRequest.patientLabel)
                    .carelyText(style: .bodyLarge, weight: .semiBold)
                    .foregroundColor(.primaryFont)

                HStack(spacing: Spacing.s4) {
                    Image(systemName: "mappin.and.ellipse")
                        .resizable()
                        .scaledToFit()
                        .frame(width: IconSize.s12, height: IconSize.s12)
                    Text(jobRequest.distanceText)
                        .carelyText(style: .caption, weight: .regular)
                }
                .foregroundColor(.secondaryFont)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: Spacing.s2) {
                Text("$\(String(format: "%.2f", jobRequest.estimatedPrice.doubleValue))")
                    .carelyText(style: .bodyLarge, weight: .bold)
                    .foregroundColor(.brandPrimary)
                Text("Estimated")
                    .carelyText(style: .caption, weight: .regular)
                    .foregroundColor(.secondaryFont)
            }
        }
    }

    private var serviceRow: some View {
        HStack(spacing: Spacing.s12) {
            RoundedRectangle.carely(Radius.r8)
                .fill(Color.brandPrimary.opacity(0.1))
                .frame(width: Spacing.s32, height: Spacing.s32)
                .overlay(Image(systemName: "cross.case.fill").foregroundColor(.brandPrimary))

            Text(jobRequest.serviceName)
                .carelyText(style: .bodyRegular, weight: .semiBold)
                .foregroundColor(.primaryFont)

            Spacer()

            Image(systemName: "doc.text")
                .foregroundColor(.brandPrimary)
        }
    }

    private var sliderSection: some View {
        VStack(spacing: Spacing.s16) {
            VStack(spacing: Spacing.s4) {
                Text("$\(String(format: "%.2f", proposedPriceValue))")
                    .carelyText(style: .heading2, weight: .bold)
                    .foregroundColor(.primaryFont)
                Text("ESTIMATED PRICE")
                    .carelyText(style: .caption, weight: .semiBold)
                    .foregroundColor(.secondaryFont)
            }
            .padding(.vertical, Spacing.s8)
            .frame(width: 140)
            .background(Color.surfaceVariant.opacity(0.5))
            .clipShape(RoundedRectangle.carely(Radius.r12))

            Slider(value: $proposedPriceValue, in: jobRequest.minPrice.doubleValue...jobRequest.maxPrice.doubleValue)
                .tint(.brandPrimary)

            HStack {
                Text("$\(String(format: "%.0f", jobRequest.minPrice.doubleValue)) Min")
                Spacer()
                Text("$\(String(format: "%.0f", jobRequest.maxPrice.doubleValue)) Max")
            }
            .carelyText(style: .bodySmall, weight: .semiBold)
            .foregroundColor(.secondaryFont)
        }
    }

    private var footer: some View {
        HStack(spacing: Spacing.s12) {
            SecondaryButton(title: "Cancel", action: onCancel)
            PrimaryButton(title: "Save", action: onSave)
        }
    }
}
