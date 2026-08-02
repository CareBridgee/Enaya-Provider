//
//  StatusBadgeView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//

import SwiftUI
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
