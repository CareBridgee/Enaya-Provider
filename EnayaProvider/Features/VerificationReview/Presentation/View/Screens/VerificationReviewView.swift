//
//  VerificationReviewView.swift
//  EnayaProvider
//

import SwiftUI

struct VerificationReviewView: View {
    @StateObject var viewModel: VerificationReviewViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.s24) {

                // MARK: Header
                ApplicationStatusHeader()

                // MARK: Hero Badge
                StatusHeroBadge(
                    systemIcon: heroBadgeIcon,
                    tint: heroBadgeTint,
                    topAccessoryIcon: topAccessoryIcon,
                    bottomAccessoryIcon: bottomAccessoryIcon
                )
                .padding(.top, Spacing.s16)

                // MARK: Status-specific body
                switch viewModel.nurse.verificationStatus {
                case .underReview:
                    underReviewContent
                case .rejected:
                    rejectedContent
                default:
                    EmptyView()
                }

                // MARK: Error Banner
                if let errorMsg = viewModel.errorMessage {
                    AlertBanner(style: .error, message: errorMsg)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // MARK: Action Buttons
                actionButtons
            }
            .padding(.horizontal, Spacing.s16)
            .padding(.bottom, Spacing.s32)
        }
        .background(Color.backGround.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.3), value: viewModel.nurse.verificationStatus)
        .animation(.easeInOut(duration: 0.3), value: viewModel.errorMessage)
    }

    // MARK: - Content: Under Review

    @ViewBuilder
    private var underReviewContent: some View {
        VStack(spacing: Spacing.s8) {
            Text("Your application is under review")
                .carelyText(style: .heading3, weight: .semiBold)
                .foregroundColor(.primaryFont)
                .multilineTextAlignment(.center)

            Text("Our team is currently reviewing your submitted documents.\n\nYou'll receive access once your verification has been completed.")
                .carelyText(style: .bodySmall, weight: .regular)
                .foregroundColor(.secondaryFont)
                .multilineTextAlignment(.center)
        }

        VStack(spacing: Spacing.s4) {
            ApplicationChecklistRow(icon: "doc.text.fill",      title: "Application Received", state: .completed)
            Divider()
            ApplicationChecklistRow(icon: "shield.fill",        title: "Background Check",     state: .inProgress)
            Divider()
            ApplicationChecklistRow(icon: "checkmark.seal.fill", title: "Final Approval",      state: .pending)
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }

    // MARK: - Content: Rejected

    @ViewBuilder
    private var rejectedContent: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
           
            if let details = viewModel.nurse.rejectionDetails,
               let overall = details.overallReason {
                
                Text("Action Required")
                    .carelyText(style: .heading3, weight: .semiBold)
                    .foregroundColor(.error)
                
                Text(overall)
                    .carelyText(style: .bodySmall, weight: .regular)
                    .foregroundColor(.secondaryFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let details = viewModel.nurse.rejectionDetails,
               !details.failedSteps.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.s0) {
                    ForEach(Array(details.failedSteps.enumerated()), id: \.offset) { index, step in
                        failedStepRow(step: step)

                        if index < details.failedSteps.count - 1 {
                            Divider()
                        }
                    }
                }
                .padding(Spacing.s16)
                .background(Color.surface)
                .clipShape(RoundedRectangle.carely(Radius.r16))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func failedStepRow(step: NurseFailedStep) -> some View {
        HStack(alignment: .top, spacing: Spacing.s12) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.error)
                .frame(width: IconSize.s20)

            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text(step.step)
                    .carelyText(style: .bodyRegular, weight: .semiBold)
                    .foregroundColor(.primaryFont)

                Text(step.reason)
                    .carelyText(style: .caption, weight: .regular)
                    .foregroundColor(.secondaryFont)
            }

            Spacer(minLength: .zero)
        }
        .padding(.vertical, Spacing.s8)
    }

    // MARK: - Action Buttons

    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: Spacing.s12) {
            switch viewModel.nurse.verificationStatus {
            case .underReview:
                PrimaryButton(
                    title: viewModel.isRefreshing ? "Checking..." : "Refresh Status",
                    icon: "arrow.clockwise",
                    isLoading: viewModel.isRefreshing,
                    action: {
                        Task { await viewModel.refreshStatus() }
                    }
                )

            case .rejected:
                PrimaryButton(
                    title: "Resubmit Application",
                    icon: "arrow.up.circle.fill",
                    action: viewModel.resubmitTapped
                )

                SecondaryButton(
                    title: viewModel.isRefreshing ? "Checking Status..." : "Refresh Status",
                    icon: "arrow.clockwise",
                    isLoading: viewModel.isRefreshing,
                    action: {
                        Task { await viewModel.refreshStatus() }
                    }
                )

            default:
                EmptyView()
            }

            Button(action: { Task { await viewModel.logoutTapped() } }) {
                Text("Logout")
                    .carelyText(style: .bodySmall, weight: .medium)
                    .foregroundColor(.secondaryFont)
                    .underline()
            }
        }
    }

    // MARK: - Hero Badge Helpers

    private var heroBadgeIcon: String {
        switch viewModel.nurse.verificationStatus {
        case .underReview: return "checkmark.shield.fill"
        case .rejected:    return "exclamationmark.triangle.fill"
        default:           return "checkmark.shield.fill"
        }
    }

    private var heroBadgeTint: Color {
        switch viewModel.nurse.verificationStatus {
        case .underReview: return .brandPrimary
        case .rejected:    return .error
        default:           return .brandPrimary
        }
    }

    private var topAccessoryIcon: String? {
        viewModel.nurse.verificationStatus == .underReview ? "briefcase.fill" : nil
    }

    private var bottomAccessoryIcon: String? {
        viewModel.nurse.verificationStatus == .underReview ? "bubble.left.fill" : nil
    }
}

// MARK: - Spacing convenience
private extension CGFloat {
    static let s0: CGFloat  = 0
    static let s32: CGFloat = 32
}
