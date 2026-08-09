//
//  ChatMessageBubble.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 09/08/2026.
//


import SwiftUI

struct ChatMessageBubble: View {
    let message: ChatMessageResponseDTO
    let isCurrentUser: Bool
    let isPending: Bool
    let isFailed: Bool
    let timeText: String
    let onRetry: () -> Void

    var body: some View {
        HStack {
            if isCurrentUser { Spacer(minLength: Spacing.s48) }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: Spacing.s2) {
                Text(message.content)
                    .carelyText(style: .bodyRegular, weight: .regular)
                    .foregroundColor(isCurrentUser ? .onPrimary : .primaryFont)
                    .padding(.horizontal, Spacing.s16)
                    .padding(.vertical, Spacing.s12)
                    .background(isCurrentUser ? Color.brandPrimary : Color.surface)
                    .clipShape(RoundedRectangle.carely(Radius.r16))
                    .opacity(isPending ? 0.6 : 1.0)

                HStack(spacing: Spacing.s4) {
                    if isFailed {
                        Button(action: onRetry) {
                            Label("Failed, tap to retry", systemImage: "exclamationmark.circle.fill")
                                .carelyText(style: .caption, weight: .medium)
                                .foregroundColor(.error)
                        }
                    } else {
                        Text(timeText)
                            .carelyText(style: .caption, weight: .regular)
                            .foregroundColor(.secondaryFont)
                        if isPending {
                            ProgressView().scaleEffect(0.6)
                        }
                    }
                }
            }

            if !isCurrentUser { Spacer(minLength: Spacing.s48) }
        }
    }
}