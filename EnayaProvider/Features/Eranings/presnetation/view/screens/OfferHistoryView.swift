//
//  OfferHistoryView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 14/08/2026.
//
//  (file name kept for project-reference stability)
//

import SwiftUI

public struct HistoryView: View {
    @StateObject var viewModel: HistoryViewModel

    public var body: some View {
        ZStack {
            Color.backGround.ignoresSafeArea()

            if viewModel.isLoading && viewModel.items.isEmpty {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.s12) {
                        ForEach(0..<4, id: \.self) { _ in
                            EarningsHistoryRowSkeleton()
                        }
                    }
                    .padding(Spacing.s16)
                }
            } else if let errorMessage = viewModel.errorMessage, viewModel.items.isEmpty {
                errorState(errorMessage)
            } else if viewModel.items.isEmpty {
                emptyState
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.s12) {
                        ForEach(viewModel.items) { item in
                            historyRow(item)
                        }
                    }
                    .padding(Spacing.s16)
                }
            }
        }
        .careConnectNavigationBar(title: "History")
        .onAppear { viewModel.loadData() }
    }

    private func historyRow(_ item: NurseServiceRequestHistoryItem) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            HStack(alignment: .top, spacing: Spacing.s12) {
                AsyncImage(url: URL(string: item.patientProfileImageUrl ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Circle().fill(Color.mintSurface)
                            ProgressView()
                                .scaleEffect(0.7)
                                .tint(.brandPrimary)
                        }
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Circle().fill(Color.mintSurface).overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.brandPrimary)
                                .font(.system(size: IconSize.s20))
                        )
                    }
                }
                .frame(width: Spacing.s48, height: Spacing.s48)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: Spacing.s4) {
                    Text("\(item.serviceName.capitalized) • \(item.patientFullName)")
                        .carelyText(style: .bodySmall, weight: .bold)
                        .foregroundColor(.primaryFont)
                        .lineLimit(2)

                    Text(item.dateText)
                        .carelyText(style: .caption, weight: .regular)
                        .foregroundColor(.hint)
                }

                Spacer(minLength: Spacing.s8)

                VStack(alignment: .trailing, spacing: Spacing.s4) {
                    if let price = item.estimatedPrice {
                        Text("EGP\(NSDecimalNumber(decimal: price).doubleValue, specifier: "%.2f")")
                            .carelyText(style: .bodyRegular, weight: .bold)
                            .foregroundColor(.brandPrimary)
                    }

                    let (textColor, bgColor) = badgeColors(for: item.status)
                    StatusBadgeView(text: item.status.displayText, statusColor: textColor, bgColor: bgColor)
                }
            }

            HStack(spacing: Spacing.s16) {
                if let duration = item.estimatedDurationMinutes {
                    metaChip(icon: "clock.fill", text: "\(duration) mins")
                }
                if let phone = item.patientPhoneNumber, !phone.isEmpty {
                    metaChip(icon: "phone.fill", text: phone)
                }
                Spacer()
            }
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }

    private func metaChip(icon: String, text: String) -> some View {
        HStack(spacing: Spacing.s4) {
            Image(systemName: icon)
                .font(.system(size: IconSize.s12))
            Text(text)
                .carelyText(style: .caption, weight: .medium)
        }
        .foregroundColor(.hint)
    }

    private func badgeColors(for status: NurseServiceRequestStatus) -> (Color, Color) {
        switch status {
        case .completed, .accepted:
            return (.onSuccessContainer, .successContainer)
        case .pending, .inProgress:
            return (.onWarningContainer, .warningContainer)
        case .rejected, .expired, .cancelled:
            return (.onErrorContainer, .errorContainer)
        case .unknown:
            return (.hint, .surfaceVariant)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.s12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.hint)
            Text("No history yet")
                .carelyText(style: .bodyRegular, weight: .semiBold)
                .foregroundColor(.primaryFont)
            Text("Your past service requests will show up here.")
                .carelyText(style: .bodySmall, weight: .regular)
                .foregroundColor(.secondaryFont)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.s24)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: Spacing.s12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.error)
            Text("Couldn't load history")
                .carelyText(style: .bodyRegular, weight: .semiBold)
                .foregroundColor(.primaryFont)
            Text(message)
                .carelyText(style: .bodySmall, weight: .regular)
                .foregroundColor(.secondaryFont)
                .multilineTextAlignment(.center)

            Button(action: viewModel.retryTapped) {
                Text("Retry")
                    .carelyText(style: .bodySmall, weight: .bold)
                    .foregroundColor(.onPrimary)
                    .padding(.horizontal, Spacing.s24)
                    .padding(.vertical, Spacing.s12)
                    .background(Color.brandPrimary)
                    .clipShape(Capsule())
            }
            .padding(.top, Spacing.s8)
        }
        .padding(Spacing.s24)
    }
}
