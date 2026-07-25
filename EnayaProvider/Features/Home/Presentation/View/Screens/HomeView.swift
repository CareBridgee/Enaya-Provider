import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        ZStack {
            Color.backGround.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Spacing.s20) {
                    HomeHeaderView(providerName: viewModel.summary?.providerName ?? "", greeting: viewModel.greeting)

                    AvailabilityStatusCard(isOnline: viewModel.isOnline, onToggle: viewModel.toggleAvailability)

                    // ALWAYS VISIBLE: Earnings and Stats are now outside the online check
                    EarningsSummaryCard(amountText: viewModel.earningsText, changeText: viewModel.earningsChangeText)

                    HStack(spacing: Spacing.s12) {
                        StatCard(title: "Today's Jobs", value: viewModel.jobsCountText)
                        StatCard(title: "Rating", value: viewModel.ratingText, valueTrailingIcon: "star.fill", valueTrailingIconColor: .amber)
                    }

                    if viewModel.isOnline {
                        onlineRequestsSection
                    } else {
                        OfflineStateView(onGoOnline: viewModel.toggleAvailability)
                            .padding(.top, Spacing.s16) // Slightly reduced padding to look better below stats
                    }
                }
                .padding(.horizontal, Spacing.s16)
                .padding(.bottom, Spacing.s24)
            }
            .blur(radius: (viewModel.editingJobRequest != nil || viewModel.isWaitingForPatient) ? 3 : 0)

            // Edit Popup Overlay
            if let request = viewModel.editingJobRequest {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { viewModel.cancelEditing() }
                    .transition(.opacity)
                
                EditOfferPopupView(
                    jobRequest: request,
                    proposedPriceValue: $viewModel.proposedPriceValue,
                    onCancel: viewModel.cancelEditing,
                    onSave: viewModel.saveEditedOffer
                )
                .padding(.horizontal, Spacing.s24)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
                .zIndex(1)
            }
            
            // Waiting for Patient Overlay
            if viewModel.isWaitingForPatient {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                PatientResponseWaitingView(onCancel: viewModel.cancelWaitingOffer)
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
                    .zIndex(2)
            }
        }
        .task { await viewModel.load() }
        .alert("Request Cancelled", isPresented: errorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    @ViewBuilder
    private var onlineRequestsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            HStack {
                Text("AVAILABLE REQUESTS")
                    .carelyText(style: .caption, weight: .bold)
                    .foregroundColor(.secondaryFont)
                Spacer()
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
                    ForEach(viewModel.jobRequests) { request in
                        JobRequestCard(
                            jobRequest: request,
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
    
    private var errorBinding: Binding<Bool> {
        Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })
    }
}
