//
//  DateOfBirthField.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//

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
                HStack(spacing: Spacing.s12) {
                    Image(systemName: "calendar")
                        .foregroundColor(.hint)
                        
                    Text(displayText)
                        .carelyText(style: .bodyRegular)
                        .foregroundColor(date == nil ? .hint : .primaryFont)
                    Spacer()
                }
                .padding(.horizontal, Spacing.s16)
                .frame(height: CarelyTextFieldSize.medium.height)
                .background(Color.surfaceVariant)
                .clipShape(RoundedRectangle.carely(Radius.r12))

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
