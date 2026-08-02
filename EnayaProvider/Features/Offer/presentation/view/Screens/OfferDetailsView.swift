//
//  OfferDetailsView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI

struct OfferDetailsView: View {
    @ObservedObject var coordinator: OfferCoordinator
    @StateObject var viewModel: OfferDetailsViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.s16) {
                scheduleCard

                OfferPatientCard(
                    name: coordinator.offer.patient.name,
                    ageText: coordinator.offer.patient.ageText,
                    caption: "Patient",
                    captionValue: "",
                    onCall: {},
                    onMessage: {}
                )

                serviceCard

                Button(action: viewModel.viewPatientSummaryTapped) {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("View patient summary")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .carelyText(style: .bodySmall, weight: .medium)
                    .foregroundColor(.primaryFont)
                    .padding(Spacing.s16)
                    .background(Color.surface)
                    .clipShape(RoundedRectangle.carely(Radius.r16))
                }

                VStack(alignment: .leading, spacing: Spacing.s8) {
                    OfferSectionLabel(title: "Location", trailingTitle: "Copy Address", onTrailingTapped: viewModel.copyAddressTapped)
                    OfferMapAddressCard(address: coordinator.offer.address, onOpenInMaps: viewModel.openInMapsTapped)
                }

                paymentCard
            }
            .padding(.horizontal, Spacing.s16)
            .padding(.top, Spacing.s16)
            .padding(.bottom, Spacing.s24)
        }
        .background(Color.backGround.ignoresSafeArea())
        .careConnectNavigationBar(title: "Offer Details")
    }

    private var scheduleCard: some View {
        HStack(spacing: Spacing.s12) {
            Image(systemName: "calendar")
                .foregroundColor(.brandPrimary)
            Text(coordinator.offer.scheduledDateText)
                .carelyText(style: .bodyRegular, weight: .semiBold)
                .foregroundColor(.primaryFont)
            Spacer()
            Text(coordinator.offer.scheduledTimeText)
                .carelyText(style: .bodyRegular, weight: .bold)
                .foregroundColor(.brandPrimary)
        }
        .padding(Spacing.s16)
        .background(Color.mintSurface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }

    private var serviceCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            HStack {
                OfferSectionLabel(title: "Service Type")
                Spacer()
                Text("Estimated duration")
                    .carelyText(style: .caption, weight: .regular)
                    .foregroundColor(.secondaryFont)
            }

            HStack {
                Label(coordinator.offer.serviceName, systemImage: coordinator.offer.serviceIcon)
                    .carelyText(style: .bodyRegular, weight: .semiBold)
                    .foregroundColor(.primaryFont)
                Spacer()
                Text("\(coordinator.offer.durationMinutes) mins")
                    .carelyText(style: .bodyRegular, weight: .semiBold)
                    .foregroundColor(.primaryFont)
            }
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }

    private var paymentCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            OfferSectionLabel(title: "Payment Summary")

            HStack {
                Text("Total Amount")
                    .carelyText(style: .bodyRegular, weight: .medium)
                    .foregroundColor(.primaryFont)
                Spacer()
                Text("$\(String(format: "%.2f", NSDecimalNumber(decimal: coordinator.offer.totalAmount).doubleValue))")
                    .carelyText(style: .bodyLarge, weight: .bold)
                    .foregroundColor(.primaryFont)
            }

            HStack(spacing: Spacing.s8) {
                Image(systemName: "creditcard.fill").foregroundColor(.hint)
                Text("Payment will be processed after completion")
                    .carelyText(style: .caption, weight: .regular)
                    .foregroundColor(.secondaryFont)
            }
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
}