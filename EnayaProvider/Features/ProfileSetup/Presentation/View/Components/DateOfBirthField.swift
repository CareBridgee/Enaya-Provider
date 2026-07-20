import SwiftUI

struct DateOfBirthField: View {
    @Binding var date: Date?

    private var displayText: String {
        guard let date else { return "mm/dd/yyyy" }
        return date.formatted(.dateTime.month(.twoDigits).day(.twoDigits).year())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text("Date of Birth")
                .carelyText(style: .bodySmall, weight: .medium)
                .foregroundColor(.secondaryFont)

            ZStack(alignment: .leading) {
                HStack {
                    Text(displayText)
                        .carelyText(style: .bodyRegular)
                        .foregroundColor(date == nil ? .hint : .primaryFont)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(.hint)
                }
                .padding(.horizontal, Spacing.s16)
                .frame(height: CarelyTextFieldSize.medium.height)
                .background(Color.surfaceVariant)
                .clipShape(RoundedRectangle.trueFit(Radius.r12))

                DatePicker(
                    "",
                    selection: Binding(get: { date ?? Date() }, set: { date = $0 }),
                    displayedComponents: .date
                )
                .labelsHidden()
                .blendMode(.destinationOver)
            }
        }
    }
}