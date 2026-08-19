//
//  EarningsHistoryView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//

import SwiftUI

public struct EarningsHistoryView: View {
    @StateObject var viewModel: EarningsHistoryViewModel

    public var body: some View {
        VStack(spacing: Spacing.s0) {
            //TabCustomHeader(title: "Serene Care")

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Spacing.s24) {
                    earningsSummaryCard

                    serviceEarningsSection
                }
                .padding(Spacing.s16)
            }
        }
        .background(Color.backGround.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear { viewModel.loadData() }
    }

    private var earningsSummaryCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text("Total Earnings")
                    .carelyText(style: .bodySmall, weight: .medium)
                    .foregroundColor(.onPrimary.opacity(0.9))

                Text(String(format: "EGP %.2f", NSDecimalNumber(decimal: viewModel.totalEarnings).doubleValue))
                    .carelyText(style: .heading1, weight: .bold)
                    .foregroundColor(.onPrimary)
            }

            HStack(spacing: Spacing.s12) {
                HStack(spacing: Spacing.s4) {
                    Image(systemName: "checkmark.circle")
                    Text("\(viewModel.jobsCount) Jobs")
                }
                .carelyText(style: .bodySmall, weight: .medium)
                .foregroundColor(.onPrimary)
                .padding(.horizontal, Spacing.s12)
                .padding(.vertical, Spacing.s8)
                .background(Color.white.opacity(0.2))
                .clipShape(Capsule())

                Spacer()
            }

            Button(action: viewModel.viewPayoutsTapped) {
                HStack(spacing: Spacing.s4) {
                    Image(systemName: "wallet.pass")
                    Text("View Payouts")
                }
                .carelyText(style: .bodySmall, weight: .bold)
                .foregroundColor(.brandPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.s8)
                .background(Color.surface)
                .clipShape(Capsule())
            }
        }
        .padding(Spacing.s20)
        .background(Color.brandPrimary)
        .clipShape(RoundedRectangle.carely(Radius.r20))
    }

    private var serviceEarningsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            Text("Service Earnings")
                .carelyText(style: .heading3, weight: .bold)
                .foregroundColor(.primaryFont)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.s8) {
                    serviceFilterMenu
                    thisMonthChip
                    sortMenu
                }
            }

            if viewModel.isLoading && viewModel.items.isEmpty {
                VStack(spacing: Spacing.s12) {
                    ForEach(0..<4, id: \.self) { _ in
                        EarningsHistoryRowSkeleton()
                    }
                }
            } else if let errorMessage = viewModel.errorMessage, viewModel.items.isEmpty {
                errorState(errorMessage)
            } else if viewModel.items.isEmpty {
                viewModel.isFiltering ? AnyView(noFilterResultsState) : AnyView(emptyState)
            } else {
                VStack(spacing: Spacing.s12) {
                    ForEach(viewModel.items) { item in
                        jobRow(item)
                    }
                }
            }
        }
    }

    private func jobRow(_ item: NurseServiceRequestHistoryItem) -> some View {
        HStack(alignment: .top, spacing: Spacing.s12) {
            
            // Patient Image with Person Fallback
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
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    Circle()
                        .fill(Color.mintSurface)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.brandPrimary)
                                .font(.system(size: IconSize.s20))
                        )
                }
            }
            .frame(width: Spacing.s48, height: Spacing.s48)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text("\(item.serviceName.capitalized) from \(item.patientFullName)")
                    .carelyText(style: .bodySmall, weight: .bold)
                    .foregroundColor(.primaryFont)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.9)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.dateText)
                    .carelyText(style: .caption, weight: .regular)
                    .foregroundColor(.hint)
                    .padding(.top, Spacing.s2)
            }

            Spacer(minLength: Spacing.s8)

            VStack(alignment: .trailing, spacing: Spacing.s4) {
                if let priceDecimal = item.estimatedPrice {
                    let rawPrice = NSDecimalNumber(decimal: priceDecimal).doubleValue
                    let appFee = min(rawPrice * 0.20, 120.0)
                    let nurseEarning = rawPrice - appFee
                    
                    Text(String(format: "EGP %.2f", nurseEarning))
                        .carelyText(style: .bodyRegular, weight: .bold)
                        .foregroundColor(.brandPrimary)
                }

                let (textColor, bgColor) = badgeColors(for: item.status)
                StatusBadgeView(text: item.status.displayText, statusColor: textColor, bgColor: bgColor)
            }
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
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

    private var serviceFilterMenu: some View {
        Menu {
            Button {
                viewModel.selectService(nil)
            } label: {
                if viewModel.selectedService == nil {
                    Label("All Services", systemImage: "checkmark")
                } else {
                    Text("All Services")
                }
            }

            ForEach(viewModel.availableServices, id: \.self) { service in
                Button {
                    viewModel.selectService(service)
                } label: {
                    if viewModel.selectedService == service {
                        Label(service.capitalized, systemImage: "checkmark")
                    } else {
                        Text(service.capitalized)
                    }
                }
            }
        } label: {
            EarningsFilterChip(
                title: viewModel.selectedService?.capitalized ?? "All Services",
                icon: "briefcase.fill",
                isSelected: viewModel.selectedService != nil
            )
        }
    }

    private var thisMonthChip: some View {
        Button {
            viewModel.setTimeFilter(viewModel.timeFilter == .thisMonth ? .all : .thisMonth)
        } label: {
            EarningsFilterChip(
                title: "This Month",
                icon: "calendar",
                isSelected: viewModel.timeFilter == .thisMonth
            )
        }
    }

    private var sortMenu: some View {
        Menu {
            ForEach(EarningsSortOption.allCases) { option in
                Button {
                    viewModel.setSortOption(option)
                } label: {
                    if viewModel.sortOption == option {
                        Label(option.rawValue, systemImage: "checkmark")
                    } else {
                        Text(option.rawValue)
                    }
                }
            }
        } label: {
            EarningsFilterChip(
                title: viewModel.sortOption == .newest ? "Sort" : viewModel.sortOption.rawValue,
                icon: "line.3.horizontal.decrease",
                isSelected: viewModel.sortOption != .newest
            )
        }
    }

    private var noFilterResultsState: some View {
        VStack(spacing: Spacing.s12) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 40))
                .foregroundColor(.hint)
            Text("No matching earnings")
                .carelyText(style: .bodyRegular, weight: .semiBold)
                .foregroundColor(.primaryFont)
            Text("Try a different service or time range.")
                .carelyText(style: .bodySmall, weight: .regular)
                .foregroundColor(.secondaryFont)
                .multilineTextAlignment(.center)

            Button(action: viewModel.clearFilters) {
                Text("Clear Filters")
                    .carelyText(style: .bodySmall, weight: .bold)
                    .foregroundColor(.onPrimary)
                    .padding(.horizontal, Spacing.s24)
                    .padding(.vertical, Spacing.s12)
                    .background(Color.brandPrimary)
                    .clipShape(Capsule())
            }
            .padding(.top, Spacing.s8)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.s24)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.s12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.hint)
            Text("No earnings yet")
                .carelyText(style: .bodyRegular, weight: .semiBold)
                .foregroundColor(.primaryFont)
            Text("Your completed service requests will show up here.")
                .carelyText(style: .bodySmall, weight: .regular)
                .foregroundColor(.secondaryFont)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.s24)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: Spacing.s12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.error)
            Text("Couldn't load earnings")
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
        .frame(maxWidth: .infinity)
        .padding(Spacing.s24)
    }
}

// MARK: - Earnings History Row Skeleton

public struct EarningsHistoryRowSkeleton: View {
    public init() {}

    public var body: some View {
        HStack(alignment: .top, spacing: Spacing.s12) {
            EtmaenSkeletonCircle(size: Spacing.s48)

            VStack(alignment: .leading, spacing: Spacing.s4) {
                EtmaenSkeletonRect(width: 140, height: 14, radius: Radius.r8)
                EtmaenSkeletonRect(width: 80, height: 10, radius: Radius.r8)
            }

            Spacer(minLength: Spacing.s8)

            VStack(alignment: .trailing, spacing: Spacing.s4) {
                EtmaenSkeletonRect(width: 50, height: 14, radius: Radius.r8)
                EtmaenSkeletonRect(width: 60, height: 16, radius: Radius.r8)
            }
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
}
