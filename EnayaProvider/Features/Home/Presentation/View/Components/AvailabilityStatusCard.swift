//
//  AvailabilityStatusCard.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import SwiftUI

struct AvailabilityStatusCard: View {
    let isOnline: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: Spacing.s8) {
            Circle()
                .fill(isOnline ? Color.success : Color.hint)
                .frame(width: Spacing.s8, height: Spacing.s8)

            Text(isOnline ? "Status: Online" : "Status: Offline")
                .carelyText(style: .bodyRegular, weight: .medium)
                .foregroundColor(.primaryFont)

            Spacer()

            Toggle("", isOn: Binding(get: { isOnline }, set: { _ in onToggle() }))
                .labelsHidden()
                .tint(.brandPrimary)
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.trueFit(Radius.r16))
    }
}