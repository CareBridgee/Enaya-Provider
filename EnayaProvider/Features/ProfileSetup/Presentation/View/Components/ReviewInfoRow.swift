import SwiftUI

struct ReviewInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s4) {
            Text(label)
                .carelyText(style: .caption, weight: .regular)
                .foregroundColor(.secondaryFont)
            Text(value)
                .carelyText(style: .bodyRegular, weight: .medium)
                .foregroundColor(.primaryFont)
        }
    }
}

struct ReviewDocumentRow: View {
    let icon: String
    let name: String

    var body: some View {
        HStack(spacing: Spacing.s12) {
            Image(systemName: icon)
                .foregroundColor(.brandPrimary)
            
            Text(name)
                .carelyText(style: .bodySmall, weight: .medium)
                .foregroundColor(.primaryFont)
                .lineLimit(1)
            
            Spacer()
            
            Image(systemName: "checkmark.circle")
                .foregroundColor(.success)
        }
        .padding(Spacing.s12)
        .background(Color.surfaceVariant)
        .clipShape(RoundedRectangle.carely(Radius.r12))
    }
}