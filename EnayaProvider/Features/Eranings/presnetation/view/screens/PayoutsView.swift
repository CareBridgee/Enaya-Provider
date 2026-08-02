//
//  PayoutsView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI

public struct PayoutsView: View {
    @StateObject var viewModel: PayoutsViewModel

    public var body: some View {
        VStack(spacing: Spacing.s0) {
            TabCustomHeader(title: "Payouts & Withdrawals")
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.s20) {
                    if let summary = viewModel.summary {
                        availablePayoutCard(summary)
                        statsRow(summary)
                    }
                    
                    Button(action: viewModel.goBackTapped) {
                        HStack(spacing: Spacing.s4) {
                            Image(systemName: "arrow.left")
                            Text("Back to Service Earnings")
                        }
                        .carelyText(style: .bodySmall, weight: .bold)
                        .foregroundColor(.brandPrimary)
                    }
                    .padding(.top, Spacing.s8)
                    
                    Text("Withdraw History")
                        .carelyText(style: .heading3, weight: .bold)
                        .foregroundColor(.primaryFont)
                    
                    VStack(spacing: Spacing.s12) {
                        ForEach(viewModel.history) { tx in
                            payoutRow(tx)
                        }
                    }
                }
                .padding(Spacing.s16)
            }
        }
        .background(Color.backGround.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear { viewModel.loadData() }
    }

    private func availablePayoutCard(_ summary: PayoutSummary) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text("Available for Payout")
                    .carelyText(style: .bodySmall, weight: .medium)
                    .foregroundColor(.secondaryFont)
                
                Text("$\(NSDecimalNumber(decimal: summary.availableForPayout).doubleValue, specifier: "%.2f")")
                    .carelyText(style: .heading1, weight: .bold)
                    .foregroundColor(.brandPrimary)
            }
            
            PrimaryButton(title: "Withdraw Now", size: .medium, radius: Radius.r12) {}
        }
        .padding(Spacing.s20)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r20))
        // Replicating TrueFit layered shadow concept if available, else standard
        .shadow(color: .black.opacity(0.04), radius: Radius.r16, x: 0, y: 8) 
    }

    private func statsRow(_ summary: PayoutSummary) -> some View {
        HStack(spacing: Spacing.s12) {
            statCard(title: "PENDING", amount: summary.pending, color: .secondaryFont)
            statCard(title: "THIS MONTH", amount: summary.thisMonth, color: .brandPrimary)
        }
    }

    private func statCard(title: String, amount: Decimal, color: Color) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s4) {
            Text(title)
                .carelyText(style: .caption, weight: .bold)
                .foregroundColor(.hint)
            
            Text("$\(NSDecimalNumber(decimal: amount).doubleValue, specifier: "%.2f")")
                .carelyText(style: .heading3, weight: .bold)
                .foregroundColor(color)
        }
        .padding(Spacing.s16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }

    private func payoutRow(_ tx: PayoutTransaction) -> some View {
        HStack(spacing: Spacing.s12) {
            Circle()
                .fill(Color.mintSurface)
                .frame(width: Spacing.s48, height: Spacing.s48)
                .overlay(
                    Image(systemName: tx.methodType.icon)
                        .foregroundColor(tx.methodType == .instant ? .error : .brandPrimary)
                        .font(.system(size: IconSize.s20))
                )
            
            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text(tx.methodType.rawValue)
                    .carelyText(style: .bodySmall, weight: .bold)
                    .foregroundColor(.primaryFont)
                
                Text(tx.dateText)
                    .carelyText(style: .caption, weight: .regular)
                    .foregroundColor(.hint)
            }
            
            Spacer(minLength: .zero)
            
            VStack(alignment: .trailing, spacing: Spacing.s4) {
                Text("$\(NSDecimalNumber(decimal: tx.amount).doubleValue, specifier: "%.2f")")
                    .carelyText(style: .bodyRegular, weight: .bold)
                    .foregroundColor(.primaryFont)
                
                let (textColor, bgColor) = payoutBadgeColors(for: tx.status)
                StatusBadgeView(text: tx.status.rawValue, statusColor: textColor, bgColor: bgColor)
            }
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }

    private func payoutBadgeColors(for status: PayoutTransactionStatus) -> (Color, Color) {
        switch status {
        case .completed: return (.onSuccessContainer, .successContainer)
        case .pending: return (.hint, .surfaceVariant)
        case .failed: return (.onErrorContainer, .errorContainer)
        }
    }
}