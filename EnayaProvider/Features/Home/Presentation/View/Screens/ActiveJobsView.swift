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
            AppHeader(title: "Pending Requested", showBackButton: false)
                .padding(.horizontal, Spacing.s16)
                .background(Color.backGround)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Spacing.s16) {
                    if viewModel.isOnline {
                        if viewModel.jobRequests.isEmpty {
                            VStack(spacing: Spacing.s8) {
                                Text("No pending requests at the moment.")
                                    .carelyText(style: .bodySmall, weight: .regular)
                                    .foregroundColor(.secondaryFont)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.s32)
                        } else {
                            requestsSummaryCard
                            
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
    }
    
    private var requestsSummaryCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text("CURRENT REQUESTS")
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
