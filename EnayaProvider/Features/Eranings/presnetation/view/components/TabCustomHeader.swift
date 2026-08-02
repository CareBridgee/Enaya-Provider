//
//  TabCustomHeader.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI

// MATCHING FIGMA HEADER
struct TabCustomHeader: View {
    let title: String
    
    var body: some View {
        HStack(spacing: Spacing.s12) {
            Image("mock_avatar") // Ensure an asset exists, or use a placeholder
                .resizable()
                .frame(width: Spacing.s40, height: Spacing.s40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.surfaceVariant, lineWidth: 1))
            
            Text(title)
                .carelyText(style: .heading3, weight: .bold)
                .foregroundColor(.brandPrimary)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.system(size: IconSize.s20))
                    .foregroundColor(.primaryFont)
            }
        }
        .padding(.horizontal, Spacing.s16)
        .padding(.vertical, Spacing.s8)
        .background(Color.backGround)
    }
}

// MATCHING FIGMA STATUS BADGE
struct StatusBadgeView: View {
    let text: String
    let statusColor: Color
    let bgColor: Color
    
    var body: some View {
        Text(text)
            .carelyText(style: .caption, weight: .bold)
            .foregroundColor(statusColor)
            .padding(.horizontal, Spacing.s8)
            .padding(.vertical, Spacing.s4)
            .background(bgColor)
            .clipShape(Capsule())
    }
}

// MATCHING FIGMA FILTER CHIPS
struct EarningsFilterChip: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: Spacing.s4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: IconSize.s12))
            }
            Text(title)
                .carelyText(style: .bodySmall, weight: .medium)
        }
        .foregroundColor(isSelected ? .onPrimary : .primaryFont)
        .padding(.horizontal, Spacing.s16)
        .padding(.vertical, Spacing.s8)
        .background(isSelected ? Color.brandPrimary : Color.surfaceVariant)
        .clipShape(Capsule())
    }
}