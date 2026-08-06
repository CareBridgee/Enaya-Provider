//
//  ChecklistItemState.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import SwiftUI

enum ChecklistItemState {
    case completed
    case inProgress
    case pending
}

struct ApplicationChecklistRow: View {
    let icon: String
    let title: String
    let state: ChecklistItemState

    var body: some View {
        HStack(spacing: Spacing.s12) {
            Image(systemName: icon)
                .foregroundColor(.secondaryFont)
                .frame(width: IconSize.s20)

            Text(title)
                .carelyText(style: .bodyRegular, weight: .medium)
                .foregroundColor(.primaryFont)

            Spacer()

            statusView
        }
        .padding(.vertical, Spacing.s8)
    }

    @ViewBuilder
    private var statusView: some View {
        switch state {
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.success)
        case .inProgress:
            Text("In Progress")
                .carelyText(style: .caption, weight: .medium)
                .foregroundColor(.brandPrimary)
        case .pending:
            Text("Pending")
                .carelyText(style: .caption, weight: .medium)
                .foregroundColor(.hint)
        }
    }
}