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
        ZStack {
            Color.backGround.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Loading live details...")
            } else if viewModel.requestDetails != nil {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.s16) {
                        scheduleCard
                        
                        OfferPatientCard(
                            name: viewModel.patientFullName,
                            ageText: viewModel.patientAge,
                            caption: "Patient",
                            captionValue: "",
                            imageUrl: viewModel.patientImageUrl,
                            onCall: viewModel.callPatientTapped,
                            onMessage: viewModel.openChatTapped
                        )

                        serviceCard

                        VStack(alignment: .leading, spacing: Spacing.s8) {
                            OfferSectionLabel(title: "LOCATION", trailingTitle: "Copy Address", onTrailingTapped: viewModel.copyAddressTapped)
                            
                            OfferMapAddressCard(
                                addressLine: viewModel.addressLine,
                                addressDetail: viewModel.addressDetail,
                                onOpenInMaps: viewModel.openInMapsTapped
                            )
                        }

                        paymentCard
                    }
                    .padding(.horizontal, Spacing.s16)
                    .padding(.top, Spacing.s16)
                    .padding(.bottom, Spacing.s24)
                }
            } else if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            }
        }
        .careConnectNavigationBar(title: "Offer Details")
        .task {
            await viewModel.fetchData()
        }
        .alert("Notice", isPresented: $viewModel.showPhoneAlert) {
                   Button("OK", role: .cancel) { }
               } message: {
                   Text(viewModel.phoneAlertMessage)
               }
               .alert("Request Cancelled", isPresented: $viewModel.showPatientCancelledAlert) {
                           Button("OK", role: .cancel) {
                               viewModel.handlePatientCancellationAcknowledged()
                           }
                       } message: {
                           Text("We're sorry, the patient has cancelled this request. We are investigating the reason to ensure your compensation. You will now be redirected to the home screen.")
                       }
    }

    private var scheduleCard: some View {
        HStack(spacing: Spacing.s12) {
            Image(systemName: "calendar")
                .font(.system(size: 20))
                .foregroundColor(.brandPrimary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.scheduledDateText)
                    .carelyText(style: .bodySmall, weight: .regular)
                    .foregroundColor(.secondaryFont)
                Text(viewModel.scheduledTimeText)
                    .carelyText(style: .heading3, weight: .semiBold)
                    .foregroundColor(.brandPrimary)
            }
            Spacer()
        }
        .padding(Spacing.s16)
        .background(Color.mintSurface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }

    private var serviceCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Spacing.s4) {
                    OfferSectionLabel(title: "SERVICE TYPE")
                    HStack(spacing: Spacing.s8) {
                        Text(viewModel.serviceName)
                            .carelyText(style: .bodyLarge, weight: .semiBold)
                            .foregroundColor(.primaryFont)
                        Image(systemName: "cross.case.fill")
                            .foregroundColor(.brandPrimary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: Spacing.s4) {
                    Text("Estimated duration")
                        .carelyText(style: .caption, weight: .regular)
                        .foregroundColor(.primaryFont)
                    Text("\(viewModel.durationMinutes) mins")
                        .carelyText(style: .bodyLarge, weight: .medium)
                        .foregroundColor(.primaryFont)
                }
            }

            Button(action: viewModel.viewPatientSummaryTapped) {
                HStack {
                    Text("View patient summery")
                        .carelyText(style: .bodyRegular, weight: .regular)
                        .foregroundColor(.primaryFont)
                    Spacer()
                    Image(systemName: "doc.text")
                        .foregroundColor(.secondaryFont)
                }
                .padding(Spacing.s16)
                .background(Color.surfaceVariant.opacity(0.5))
                .clipShape(RoundedRectangle.carely(Radius.r12))
            }
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }

    private var paymentCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            OfferSectionLabel(title: "PAYMENT SUMMARY")

            HStack {
                Text("Total Amount")
                    .carelyText(style: .bodyLarge, weight: .semiBold)
                    .foregroundColor(.primaryFont)
                Spacer()
                Text("$\(String(format: "%.2f", viewModel.totalAmount))")
                    .carelyText(style: .heading3, weight: .bold)
                    .foregroundColor(.brandPrimary)
            }

            HStack(spacing: Spacing.s12) {
                Image(systemName: "creditcard.fill").foregroundColor(.brandPrimary)
                Text("Payment will be processed after completion")
                    .carelyText(style: .bodySmall, weight: .medium)
                    .foregroundColor(.primaryFont)
            }
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
}
