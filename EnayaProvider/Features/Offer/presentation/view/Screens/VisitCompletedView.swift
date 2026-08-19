//
//  VisitCompletedView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI

struct VisitCompletedView: View {
    @ObservedObject var coordinator: OfferCoordinator
    @StateObject var viewModel: VisitCompletedViewModel

    var body: some View {
        ZStack {
            Color.backGround.ignoresSafeArea()
            
            if viewModel.isLoading {
                VisitCompletedSkeletonView()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.s20) {
                        statusHero
                        summaryCard
                        payoutCard
                        PrimaryButton(title: "Return Home", action: viewModel.returnHomeTapped)
                    }
                    .padding(.horizontal, Spacing.s16)
                    .padding(.top, Spacing.s16)
                    .padding(.bottom, Spacing.s24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top) {
            AppHeader(title: AppConstants.appName, showBackButton: false)
                .padding(.horizontal, Spacing.s16)
                .background(Color.backGround)
        }
        .task {
            await viewModel.loadDetails()
        }
    }

    private var statusHero: some View {
        VStack(spacing: Spacing.s12) {
            ZStack {
                Circle().fill(Color.mintSurface).frame(width: Spacing.s64, height: Spacing.s64)
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: IconSize.s32, height: IconSize.s32)
                    .foregroundColor(.success)
            }

            Text("Visit Completed")
                .carelyText(style: .heading2, weight: .bold)
                .foregroundColor(.primaryFont)

            Text("Your session report has been finalized and submitted.")
                .carelyText(style: .bodyRegular, weight: .regular)
                .foregroundColor(.secondaryFont)
                .multilineTextAlignment(.center)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            HStack {
                OfferSectionLabel(title: "Summary Detail")
                Spacer()
                Text("Verified Visit")
                    .carelyText(style: .caption, weight: .semiBold)
                    .foregroundColor(.onSuccessContainer)
                    .padding(.horizontal, Spacing.s8)
                    .padding(.vertical, Spacing.s2)
                    .background(Color.successContainer)
                    .clipShape(Capsule())
            }

            OfferSummaryDetailGrid(items: [
                .init(icon: "person.fill", label: "Patient", value: viewModel.patientName),
                .init(icon: "cross.case.fill", label: "Service Type", value: viewModel.serviceName),
                .init(icon: "calendar", label: "Completed Date", value: viewModel.completedDateText)
            ])
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }

    private var payoutCard: some View {
        HStack {
            Text("You Will Receive".uppercased())
                .carelyText(style: .caption, weight: .bold)
                .foregroundColor(.secondaryFont)
            Spacer()
            Text("EGP\(String(format: "%.2f", viewModel.providerPayoutAmount))")
                .carelyText(style: .bodyLarge, weight: .bold)
                .foregroundColor(.brandPrimary)
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
}

// MARK: - Visit Completed Skeleton View

public struct VisitCompletedSkeletonView: View {
    public init() {}

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.s20) {
                // Status Hero Skeleton
                VStack(spacing: Spacing.s12) {
                    EtmaenSkeletonCircle(size: Spacing.s64)
                    EtmaenSkeletonRect(width: 160, height: 20, radius: Radius.r8)
                    EtmaenSkeletonRect(width: 220, height: 14, radius: Radius.r8)
                }
                .padding(.top, Spacing.s16)

                // Summary Card Skeleton
                VStack(spacing: Spacing.s16) {
                    HStack {
                        EtmaenSkeletonRect(width: 120, height: 16, radius: Radius.r8)
                        Spacer()
                        EtmaenSkeletonRect(width: 80, height: 20, radius: Radius.r12)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.s12) {
                        ForEach(0..<4, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: Spacing.s4) {
                                EtmaenSkeletonRect(width: 60, height: 10, radius: Radius.r8)
                                EtmaenSkeletonRect(width: 90, height: 14, radius: Radius.r8)
                            }
                            .padding(Spacing.s12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.surfaceVariant.opacity(0.4))
                            .cornerRadius(Radius.r12)
                        }
                    }
                }
                .padding(Spacing.s16)
                .background(Color.surface)
                .clipShape(RoundedRectangle.carely(Radius.r16))

                // Payout Card Skeleton
                HStack {
                    EtmaenSkeletonRect(width: 120, height: 14, radius: Radius.r8)
                    Spacer()
                    EtmaenSkeletonRect(width: 70, height: 18, radius: Radius.r8)
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

