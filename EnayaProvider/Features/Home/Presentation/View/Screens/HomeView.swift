import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    let onViewAll: () -> Void

    var body: some View {
        Group {
            if viewModel.summary == nil && viewModel.isLoading {
                HomeSkeletonView()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.s20) {
                        HomeHeaderView(
                            providerName: viewModel.summary?.providerName ?? "",
                            profileImageUrl: viewModel.summary?.profileImageUrl,
                            greeting: viewModel.greeting
                        )

                        AvailabilityStatusCard(isOnline: viewModel.isOnline, onToggle: { viewModel.toggleAvailability() })

                        EarningsSummaryCard(amountText: viewModel.earningsText, changeText: viewModel.earningsChangeText)

                        HStack(spacing: Spacing.s12) {
                            StatCard(title: "Today's Jobs", value: viewModel.jobsCountText)
                            StatCard(title: "Rating", value: viewModel.ratingText, valueTrailingIcon: "star.fill", valueTrailingIconColor: .amber)
                        }

                        if viewModel.isOnline {
                            onlineRequestsSection
                        } else {
                            OfflineStateView(onGoOnline: { viewModel.toggleAvailability() })
                                .padding(.top, Spacing.s16)
                        }
                    }
                    .padding(.horizontal, Spacing.s16)
                    .padding(.bottom, Spacing.s24)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.isOnline && viewModel.currentActiveVisitId != nil {
                activeVisitBanner
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(Color.backGround.ignoresSafeArea())
        .task {
            await viewModel.load()
        }
        .onAppear {
            Task {
                await viewModel.checkCurrentVisit()
            }
        }
    }

    private var activeVisitBanner: some View {
        Button(action: viewModel.returnToActiveVisit) {
            HStack(spacing: Spacing.s16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .brandPrimary))
                    .scaleEffect(1.2)
                
                VStack(alignment: .leading, spacing: Spacing.s4) {
                    Text("Active visit in progress...")
                        .carelyText(style: .bodyLarge, weight: .bold)
                        .foregroundColor(.brandPrimary)
                    
                    Text("Tap to view current patient details.")
                        .carelyText(style: .caption, weight: .medium)
                        .foregroundColor(.brandPrimary.opacity(0.7))
                }
                
                Spacer(minLength: .zero)
                
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(Spacing.s16)
            .background(Color.mintSurface)
            .clipShape(RoundedRectangle.carely(Radius.r16))
            .shadow(color: Color.black.opacity(0.08), radius: 10, y: -4)
        }
        .padding(.horizontal, Spacing.s16)
        .padding(.bottom, Spacing.s16)
    }

    @ViewBuilder
    private var onlineRequestsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            HStack {
                Text("AVAILABLE REQUESTS")
                    .carelyText(style: .caption, weight: .bold)
                    .foregroundColor(.secondaryFont)
                
                Spacer(minLength: Spacing.s0)
                
                if !viewModel.jobRequests.isEmpty {
                    Button(action: onViewAll) {
                        Text("View All")
                            .carelyText(style: .bodySmall, weight: .bold)
                            .foregroundColor(.brandPrimary)
                    }
                }
            }
            .padding(.top, Spacing.s8)

            if viewModel.jobRequests.isEmpty {
                VStack(spacing: Spacing.s8) {
                    Text("Searching for nearby requests...")
                        .carelyText(style: .bodySmall, weight: .regular)
                        .foregroundColor(.secondaryFont)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.s32)
            } else {
                VStack(spacing: Spacing.s12) {
                    ForEach(viewModel.jobRequests.prefix(2)) { request in
                        JobRequestCard(
                            jobRequest: request,
                            isActionsDisabled: viewModel.currentActiveVisitId != nil,
                            onEditOffer: { viewModel.startEditingOffer(for: request) },
                            onMakeOffer: { viewModel.submitOffer(for: request) }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity.combined(with: .scale(scale: 0.95))
                        ))
                    }
                }
            }
        }
    }
}

// MARK: - Home Skeleton View

public struct HomeSkeletonView: View {
    public init() {}

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.s20) {
                // Header Skeleton
                HStack(spacing: Spacing.s12) {
                    EtmaenSkeletonCircle(size: Spacing.s48)

                    VStack(alignment: .leading, spacing: Spacing.s4) {
                        EtmaenSkeletonRect(width: 140, height: 20, radius: Radius.r8)
                        EtmaenSkeletonRect(width: 90, height: 14, radius: Radius.r8)
                    }

                    Spacer()
                }
                .padding(.top, Spacing.s16)

                // Availability Status Skeleton
                HStack(spacing: Spacing.s8) {
                    EtmaenSkeletonCircle(size: Spacing.s8)
                    EtmaenSkeletonRect(width: 120, height: 16, radius: Radius.r8)
                    Spacer()
                    EtmaenSkeletonRect(width: 44, height: 24, radius: Radius.r12)
                }
                .padding(Spacing.s16)
                .background(Color.surface)
                .clipShape(RoundedRectangle.carely(Radius.r16))

                // Earnings Summary Skeleton
                VStack(alignment: .leading, spacing: Spacing.s12) {
                    EtmaenSkeletonRect(width: 130, height: 12, radius: Radius.r8)
                    EtmaenSkeletonRect(width: 160, height: 28, radius: Radius.r8)
                    EtmaenSkeletonRect(width: 90, height: 20, radius: Radius.r12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Spacing.s16)
                .background(Color.surface)
                .clipShape(RoundedRectangle.carely(Radius.r16))

                // Stats Skeleton
                HStack(spacing: Spacing.s12) {
                    VStack(alignment: .leading, spacing: Spacing.s8) {
                        EtmaenSkeletonRect(width: 80, height: 12, radius: Radius.r8)
                        EtmaenSkeletonRect(width: 50, height: 16, radius: Radius.r8)
                    }
                    .padding(Spacing.s16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.surface)
                    .clipShape(RoundedRectangle.carely(Radius.r16))

                    VStack(alignment: .leading, spacing: Spacing.s8) {
                        EtmaenSkeletonRect(width: 60, height: 12, radius: Radius.r8)
                        EtmaenSkeletonRect(width: 50, height: 16, radius: Radius.r8)
                    }
                    .padding(Spacing.s16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.surface)
                    .clipShape(RoundedRectangle.carely(Radius.r16))
                }

                // Available Requests Skeleton
                VStack(alignment: .leading, spacing: Spacing.s12) {
                    EtmaenSkeletonRect(width: 150, height: 14, radius: Radius.r8)
                        .padding(.top, Spacing.s8)

                    EtmaenCardSkeleton()
                    EtmaenCardSkeleton()
                }
            }
            .padding(.horizontal, Spacing.s16)
            .padding(.bottom, Spacing.s24)
        }
    }
}

