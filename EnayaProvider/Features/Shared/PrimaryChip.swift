//
//  PrimaryChip.swift
//  Carely
//
//  Created by Mina on 18/07/2026.
//
import SwiftUI

struct PrimaryChip: View {
    let image: Image
    let title: String
    var background: Color = .surface
    var foreground: Color = .brandPrimary 
    var isSelected: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(foreground)

            Text(title)
                .carelyText(style: .bodySmall, weight: .semiBold)
                .foregroundColor(isSelected ? foreground : .primaryFont)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(Spacing.s16)
        .frame(maxWidth: .infinity, alignment: .leading)
        // Light mint background when selected, solid white when unselected
        .background(isSelected ? foreground.opacity(0.1) : background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                // Faint gray border for unselected, brand color border for selected
                .stroke(isSelected ? foreground : Color.hint.opacity(0.3), lineWidth: isSelected ? 1.5 : 1)
        )
    }
}
