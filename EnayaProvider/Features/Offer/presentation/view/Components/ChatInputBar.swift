//
//  ChatInputBar.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 09/08/2026.
//


import SwiftUI

struct ChatInputBar: View {
    @Binding var text: String
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: Spacing.s8) {
            TextField("Type a message...", text: $text, axis: .vertical)
                .carelyText(style: .bodyRegular, weight: .regular)
                .padding(.horizontal, Spacing.s16)
                .padding(.vertical, Spacing.s12)
                .lineLimit(1...4)

            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: IconSize.s32, height: IconSize.s32)
                    .foregroundColor(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .hint : .brandPrimary)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, Spacing.s12)
        .padding(.vertical, Spacing.s8)
        .background(
            Capsule()
                .fill(Color.surface)
                .shadow(color: Color.black.opacity(0.12), radius: Radius.r16, x: 0, y: 8)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, Spacing.s8)
    }
}