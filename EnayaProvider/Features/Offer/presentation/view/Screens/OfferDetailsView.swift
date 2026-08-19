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
                OfferDetailsSkeletonView()
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
                Text("EGP\(String(format: "%.2f", viewModel.totalAmount))")
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

// MARK: - Offer Details Skeleton View

public struct OfferDetailsSkeletonView: View {
    public init() {}

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.s16) {
                // Schedule Card Skeleton
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.s4) {
                        EtmaenSkeletonRect(width: 80, height: 10, radius: Radius.r8)
                        EtmaenSkeletonRect(width: 140, height: 16, radius: Radius.r8)
                    }
                    Spacer()
                    EtmaenSkeletonRect(width: 70, height: 24, radius: Radius.r12)
                }
                .padding(Spacing.s16)
                .background(Color.surface)
                .clipShape(RoundedRectangle.carely(Radius.r16))

                // Patient Card Skeleton
                HStack(spacing: Spacing.s16) {
                    EtmaenSkeletonCircle(size: 56)
                    VStack(alignment: .leading, spacing: Spacing.s4) {
                        EtmaenSkeletonRect(width: 120, height: 16, radius: Radius.r8)
                        EtmaenSkeletonRect(width: 80, height: 12, radius: Radius.r8)
                    }
                    Spacer()
                    HStack(spacing: Spacing.s8) {
                        EtmaenSkeletonCircle(size: 36)
                        EtmaenSkeletonCircle(size: 36)
                    }
                }
                .padding(Spacing.s16)
                .background(Color.surface)
                .clipShape(RoundedRectangle.carely(Radius.r16))

                // Service Card Skeleton
                VStack(alignment: .leading, spacing: Spacing.s12) {
                    EtmaenSkeletonRect(width: 100, height: 12, radius: Radius.r8)
                    HStack(spacing: Spacing.s12) {
                        EtmaenSkeletonCircle(size: 40)
                        VStack(alignment: .leading, spacing: Spacing.s4) {
                            EtmaenSkeletonRect(width: 140, height: 16, radius: Radius.r8)
                            EtmaenSkeletonRect(width: 90, height: 12, radius: Radius.r8)
                        }
                    }
                }
                .padding(Spacing.s16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.surface)
                .clipShape(RoundedRectangle.carely(Radius.r16))

                // Location / Map Skeleton
                VStack(alignment: .leading, spacing: Spacing.s8) {
                    EtmaenSkeletonRect(width: 80, height: 12, radius: Radius.r8)
                    EtmaenSkeletonRect(height: 120, radius: Radius.r16)
                }

                // Payment Summary Skeleton
                VStack(alignment: .leading, spacing: Spacing.s12) {
                    EtmaenSkeletonRect(width: 120, height: 12, radius: Radius.r8)
                    HStack {
                        EtmaenSkeletonRect(width: 90, height: 14, radius: Radius.r8)
                        Spacer()
                        EtmaenSkeletonRect(width: 60, height: 18, radius: Radius.r8)
                    }
                }
                .padding(Spacing.s16)
                .background(Color.surface)
                .clipShape(RoundedRectangle.carely(Radius.r16))
            }
            .padding(.horizontal, Spacing.s16)
            .padding(.top, Spacing.s16)
            .padding(.bottom, Spacing.s24)
        }
    }
}

