//
//  CancellationReasonRow.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI

struct CancellationReasonRow: View {
    let title: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: Spacing.s12) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(isSelected ? .brandPrimary : .hint)

                Text(title)
                    .carelyText(style: .bodySmall, weight: .medium)
                    .foregroundColor(.primaryFont)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: .zero)
            }
            .padding(Spacing.s12)
            .background(Color.surfaceVariant)
            .clipShape(RoundedRectangle.carely(Radius.r12))
        }
        .buttonStyle(.plain)
    }
}