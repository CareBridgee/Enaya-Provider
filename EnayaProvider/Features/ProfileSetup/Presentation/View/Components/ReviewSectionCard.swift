//
//  ReviewSectionCard.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//

import SwiftUI

struct ReviewSectionCard<Content: View>: View {
    let title: String
    let icon: String
    let onEdit: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            HStack(spacing: Spacing.s8) {
                Image(systemName: icon)
                    .font(.system(size: IconSize.s20))
                    .foregroundColor(.brandPrimary)
                
                Text(title)
                    .carelyText(style: .bodyLarge, weight: .semiBold)
                    .foregroundColor(.brandPrimary)
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: IconSize.s20, weight: .bold))
                        .foregroundColor(.brandPrimary)
                }
            }

            content()
        }
        .padding(Spacing.s20)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
}
