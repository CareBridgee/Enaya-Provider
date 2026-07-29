//
//  ReviewSubmitFooter.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 26/07/2026.
//


import SwiftUI

struct ReviewSubmitFooter: View {
    @Binding var isCertified: Bool
    let isSubmitting: Bool
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: Spacing.s20) {
            Button(action: { isCertified.toggle() }) {
                HStack(alignment: .top, spacing: Spacing.s12) {
                    Image(systemName: isCertified ? "checkmark.square.fill" : "square")
                        .foregroundColor(isCertified ? .brandPrimary : .hint)
                        .font(.system(size: IconSize.s20))
                    
                    Text("I certify that the above information is accurate and true.")
                        .carelyText(style: .bodySmall, weight: .medium)
                        .foregroundColor(.primaryFont)
                        .multilineTextAlignment(.leading)
                    
                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            PrimaryButton(
                title: "Submit Application",
                icon: "paperplane",
                iconPosition: .trailing,
                isFullWidth: true,
                isLoading: isSubmitting,
                isEnabled: isCertified,
                action: onSubmit
            )
        }
        .padding(.horizontal, Spacing.s20)
        .padding(.top, Spacing.s20)
        .padding(.bottom, Spacing.s16)
        .background(
            Color.surface
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: -5)
        )
    }
}