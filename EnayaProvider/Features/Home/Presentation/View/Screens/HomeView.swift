import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
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
        .background(Color.backGround.ignoresSafeArea())
        .sheet(item: $viewModel.editingJobRequest) { request in
            EditOfferPopupView(
                jobRequest: request,
                proposedPriceValue: $viewModel.proposedPriceValue,
                onCancel: { viewModel.cancelEditing() },
                onSave: { viewModel.saveEditedOffer() }
            )
            .presentationDetents([.fraction(0.55), .medium])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: waitingBinding) {
            ZStack {
                Color.black.opacity(0.6).ignoresSafeArea()
                PatientResponseWaitingView(onCancel: { viewModel.cancelWaitingOffer() })
            }
            .presentationBackground(.clear)
        }
        .task { await viewModel.load() }
        .alert("Notice", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }

    private var waitingBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isWaitingForPatient },
            set: { newValue in
                if !newValue { viewModel.cancelWaitingOffer() }
            }
        )
    }

    @ViewBuilder
    private var onlineRequestsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            HStack {
                Text("AVAILABLE REQUESTS")
                    .carelyText(style: .caption, weight: .bold)
                    .foregroundColor(.secondaryFont)
                Spacer(minLength: Spacing.s0)
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
}
