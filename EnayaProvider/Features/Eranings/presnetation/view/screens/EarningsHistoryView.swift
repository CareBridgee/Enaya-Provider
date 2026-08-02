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
            TabCustomHeader(title: "Serene Care")
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Spacing.s24) {
                    if let summary = viewModel.summary {
                        earningsSummaryCard(summary)
                    }
                    
                    serviceEarningsSection
                }
                .padding(Spacing.s16)
            }
        }
        .background(Color.backGround.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear { viewModel.loadData() }
    }

    private func earningsSummaryCard(_ summary: EarningsSummary) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text("Total Earnings (This Month)")
                    .carelyText(style: .bodySmall, weight: .medium)
                    .foregroundColor(.onPrimary.opacity(0.9))
                
                Text("$\(NSDecimalNumber(decimal: summary.totalThisMonth).doubleValue, specifier: "%.2f")")
                    .carelyText(style: .heading1, weight: .bold)
                    .foregroundColor(.onPrimary)
            }
            
            HStack(spacing: Spacing.s12) {
                HStack(spacing: Spacing.s4) {
                    Image(systemName: "checkmark.circle")
                    Text("\(summary.jobsCount) Jobs")
                }
                .carelyText(style: .bodySmall, weight: .medium)
                .foregroundColor(.onPrimary)
                .padding(.horizontal, Spacing.s12)
                .padding(.vertical, Spacing.s8)
                .background(Color.white.opacity(0.2))
                .clipShape(Capsule())
                
                Spacer()
                
                Button(action: viewModel.viewPayoutsTapped) {
                    HStack(spacing: Spacing.s4) {
                        Image(systemName: "wallet.pass")
                        Text("View Payouts")
                    }
                    .carelyText(style: .bodySmall, weight: .bold)
                    .foregroundColor(.brandPrimary)
                    .padding(.horizontal, Spacing.s16)
                    .padding(.vertical, Spacing.s8)
                    .background(Color.surface)
                    .clipShape(Capsule())
                }
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
                    EarningsFilterChip(title: "All Services", icon: "briefcase.fill", isSelected: true)
                    EarningsFilterChip(title: "This Month", icon: "calendar", isSelected: false)
                    EarningsFilterChip(title: "Sort", icon: "line.3.horizontal.decrease", isSelected: false)
                }
            }
            
            VStack(spacing: Spacing.s12) {
                ForEach(viewModel.jobs) { job in
                    jobRow(job)
                }
            }
        }
    }

    private func jobRow(_ job: JobEarning) -> some View {
            HStack(alignment: .top, spacing: Spacing.s12) {
                Circle()
                    .fill(Color.mintSurface)
                    .frame(width: Spacing.s48, height: Spacing.s48)
                    .overlay(
                        Image(systemName: job.iconName)
                            .foregroundColor(.brandPrimary)
                            .font(.system(size: IconSize.s20))
                    )
                
                VStack(alignment: .leading, spacing: Spacing.s4) {
                    Text("\(job.serviceName) from \(job.patientName)")
                        .carelyText(style: .bodySmall, weight: .bold)
                        .foregroundColor(.primaryFont)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.9)
                        .fixedSize(horizontal: false, vertical: true) 
                    
                    Text(job.dateText)
                        .carelyText(style: .caption, weight: .regular)
                        .foregroundColor(.hint)
                        .padding(.top, Spacing.s2)
                }
                
                Spacer(minLength: Spacing.s8)
                
                VStack(alignment: .trailing, spacing: Spacing.s4) {
                    Text("$\(NSDecimalNumber(decimal: job.amount).doubleValue, specifier: "%.2f")")
                        .carelyText(style: .bodyRegular, weight: .bold)
                        .foregroundColor(.brandPrimary)
                    
                    let (textColor, bgColor) = badgeColors(for: job.status)
                    StatusBadgeView(text: job.status.rawValue, statusColor: textColor, bgColor: bgColor)
                }
            }
            .padding(Spacing.s16)
            .background(Color.surface)
            .clipShape(RoundedRectangle.carely(Radius.r16))
        }

    private func badgeColors(for status: JobEarningStatus) -> (Color, Color) {
        switch status {
        case .completed: return (.onSuccessContainer, .successContainer)
        case .processing: return (.onProcessingContainer, .processingContainer)
        case .canceled: return (.onErrorContainer, .errorContainer)
        }
    }
}
