import SwiftUI

struct ReviewSectionCard: View {
    let title: String
    let onEdit: () -> Void
    let rows: [(label: String, value: String)]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            HStack {
                Text(title)
                    .carelyText(style: .bodyRegular, weight: .semiBold)
                    .foregroundColor(.brandPrimary)
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.hint)
                }
            }

            VStack(alignment: .leading, spacing: Spacing.s8) {
                ForEach(rows, id: \.label) { row in
                    VStack(alignment: .leading, spacing: Spacing.s2) {
                        Text(row.label)
                            .carelyText(style: .caption, weight: .regular)
                            .foregroundColor(.secondaryFont)
                        Text(row.value)
                            .carelyText(style: .bodyRegular, weight: .medium)
                            .foregroundColor(.primaryFont)
                    }
                }
            }
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.trueFit(Radius.r16))
    }
}