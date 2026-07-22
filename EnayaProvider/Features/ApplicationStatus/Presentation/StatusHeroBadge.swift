//
//  StatusHeroBadge.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import SwiftUI

struct StatusHeroBadge: View {
    private let outerRingSize: CGFloat = 160
    private let circleSize: CGFloat = 120
    private let accessorySize: CGFloat = 40
    private let accessoryOffset: CGFloat = 55

    let systemIcon: String
    let tint: Color
    var topAccessoryIcon: String? = nil
    var bottomAccessoryIcon: String? = nil

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.2), lineWidth: 1)
                .frame(width: outerRingSize, height: outerRingSize)

            Circle()
                .fill(Color.surface)
                .frame(width: circleSize, height: circleSize)
                .shadow(color: .black.opacity(0.06), radius: Radius.r12, y: Spacing.s4)

            Image(systemName: systemIcon)
                .resizable()
                .scaledToFit()
                .frame(width: IconSize.s32, height: IconSize.s32)
                .foregroundColor(tint)

            if let topAccessoryIcon {
                accessoryBadge(topAccessoryIcon)
                    .offset(x: accessoryOffset, y: -accessoryOffset)
            }

            if let bottomAccessoryIcon {
                accessoryBadge(bottomAccessoryIcon)
                    .offset(x: -accessoryOffset, y: accessoryOffset)
            }
        }
        .frame(width: outerRingSize, height: outerRingSize)
    }

    private func accessoryBadge(_ icon: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.surface)
                .frame(width: accessorySize, height: accessorySize)
                .shadow(color: .black.opacity(0.08), radius: Spacing.s4, y: Spacing.s2)
            Image(systemName: icon)
                .foregroundColor(.secondaryFont)
        }
    }
}
