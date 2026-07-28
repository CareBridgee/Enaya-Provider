import SwiftUI

struct ReviewProgressIndicator: View {
    var body: some View {
        HStack {
            ReviewProgressStep(icon: "checkmark.circle.fill", title: "Details", color: .success)
            ReviewProgressLine()
            ReviewProgressStep(icon: "checkmark.circle.fill", title: "Services", color: .success)
            ReviewProgressLine()
            ReviewProgressStep(number: "3", title: "Review", color: .brandPrimary)
        }
        .padding(.vertical, Spacing.s8)
    }
}

struct ReviewProgressStep: View {
    var icon: String? = nil
    var number: String? = nil
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: Spacing.s8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            } else if let number = number {
                Circle()
                    .fill(color)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text(number)
                            .carelyText(style: .caption, weight: .bold)
                            .foregroundColor(.white)
                    )
            }
            Text(title)
                .carelyText(style: .caption, weight: .semiBold)
                .foregroundColor(color)
        }
    }
}

struct ReviewProgressLine: View {
    var body: some View {
        Rectangle()
            .fill(Color.divider)
            .frame(height: 1)
            .padding(.horizontal, Spacing.s8)
            .padding(.bottom, Spacing.s16)
    }
}