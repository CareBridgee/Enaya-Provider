//
//  ProviderTabBar.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import SwiftUI

struct ProviderTabBar: View {
    @Binding var selectedTab: AppTab
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        HStack(spacing: Spacing.s0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, Spacing.s8)
        .padding(.top, Spacing.s12)
        .background(Color.surface.ignoresSafeArea(edges: .bottom))
        .shadow(color: .black.opacity(0.06), radius: Radius.r12, y: -4)
    }

    @ViewBuilder
    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = selectedTab == tab

        Button {
            select(tab)
        } label: {
            VStack(spacing: Spacing.s4) {
                Image(systemName: tab.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: IconSize.s24, height: IconSize.s24)

                Text(tab.title)
                    .carelyText(style: .caption, weight: isSelected ? .bold : .medium)
            }
            .foregroundColor(isSelected ? .brandPrimary : .secondaryFont)
            .padding(.vertical, Spacing.s8)
            .padding(.horizontal, Spacing.s16)
            .background(isSelected ? Color.mintSurface : Color.clear)
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func select(_ tab: AppTab) {
        guard tab != selectedTab else { return }
        hapticGenerator.impactOccurred()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            selectedTab = tab
        }
    }
}
