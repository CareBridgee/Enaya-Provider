//
//  ActiveJobsView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 13/08/2026.
//

import SwiftUI

struct ActiveJobsView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Requested", showBackButton: false)
                .padding(.horizontal, Spacing.s16)
                .background(Color.backGround)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Spacing.s16) {
                    if viewModel.isOnline {
                        
                        requestsSummaryCard
                            .padding(.bottom, Spacing.s8)
                        
                        if viewModel.isLoading && viewModel.jobRequests.isEmpty {
                            VStack(spacing: Spacing.s12) {
                                ActiveJobCardSkeleton()
                                ActiveJobCardSkeleton()
                                ActiveJobCardSkeleton()
                            }
                        } else if viewModel.jobRequests.isEmpty {
                            // Updated Empty State to match the design
                            VStack(spacing: Spacing.s8) {
                                Text("No Requests Available")
                                    .carelyText(style: .heading3, weight: .bold)
                                    .foregroundColor(.primaryFont)
                                
                                Text("Incoming requests from nearby patients\nwill appear here in real-time.")
                                    .carelyText(style: .bodyRegular, weight: .regular)
                                    .foregroundColor(.secondaryFont)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, Spacing.s16)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, Spacing.s32)
                            
                        } else {
                            ForEach(viewModel.jobRequests) { request in
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
                    } else {
                        OfflineStateView(onGoOnline: { viewModel.toggleAvailability() })
                            .padding(.top, Spacing.s16)
                    }
                }
                .padding(.horizontal, Spacing.s16)
                .padding(.top, Spacing.s16)
                .padding(.bottom, Spacing.s32)
            }
            .safeAreaInset(edge: .bottom) {
                if viewModel.isOnline && viewModel.currentActiveVisitId != nil {
                    activeVisitBanner
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .background(Color.backGround.ignoresSafeArea())
        .onAppear {
            Task {
                await viewModel.checkCurrentVisit()
            }
        }
    }
    
    private var requestsSummaryCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text("CURRENT REQUEST")
                    .carelyText(style: .caption, weight: .bold)
                    .foregroundColor(.secondaryFont)
                
                Text("Post-Op Home Care")
                    .carelyText(style: .heading3, weight: .bold)
                    .foregroundColor(.onInfoContainer)
                    .lineLimit(1)
            }
            
            Spacer(minLength: Spacing.s12)
            
            Text("\(viewModel.jobRequests.count) Offers")
                .carelyText(style: .bodySmall, weight: .medium)
                .foregroundColor(.brandPrimary)
                .padding(.horizontal, Spacing.s16)
                .padding(.vertical, Spacing.s8)
                .background(Color.surface)
                .clipShape(Capsule())
        }
        .padding(Spacing.s16)
        .background(Color.mintSurface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
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
}

// MARK: - Active Job Card Skeleton

public struct ActiveJobCardSkeleton: View {
    public init() {}

    public var body: some View {
        VStack(spacing: Spacing.s16) {
            HStack(alignment: .top, spacing: Spacing.s12) {
                EtmaenSkeletonCircle(size: Spacing.s48)

                VStack(alignment: .leading, spacing: Spacing.s4) {
                    EtmaenSkeletonRect(width: 130, height: 16, radius: Radius.r8)
                    EtmaenSkeletonRect(width: 80, height: 12, radius: Radius.r8)
                }

                Spacer()

                EtmaenSkeletonRect(width: 60, height: 24, radius: Radius.r12)
            }

            HStack(spacing: Spacing.s12) {
                EtmaenSkeletonRect(width: 100, height: 14, radius: Radius.r8)
                Spacer()
                EtmaenSkeletonRect(width: 70, height: 14, radius: Radius.r8)
            }
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
        .shadow(color: Color.black.opacity(0.04), radius: Radius.r8, y: Spacing.s2)
    }
}
