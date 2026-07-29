//
//  SelectionField.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//

import SwiftUI

struct SelectionField<Option: Identifiable & Hashable>: View {
    let label: String
    let placeholder: String
    var leadingIcon: String? = nil 
    let options: [Option]
    let optionTitle: (Option) -> String
    @Binding var selection: Option?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text(label)
                .carelyText(style: .bodySmall, weight: .medium)
                .foregroundColor(.secondaryFont)

            Menu {
                ForEach(options) { option in
                    Button(optionTitle(option)) { selection = option }
                }
            } label: {
                HStack(spacing: Spacing.s12) {
                    if let leadingIcon = leadingIcon {
                        Image(systemName: leadingIcon)
                            .foregroundColor(.hint)
                    }
                    
                    Text(selection.map(optionTitle) ?? placeholder)
                        .carelyText(style: .bodyRegular)
                        .foregroundColor(selection == nil ? .hint : .primaryFont)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundColor(.hint)
                }
                .padding(.horizontal, Spacing.s16)
                .frame(height: CarelyTextFieldSize.medium.height)
                .background(Color.surfaceVariant)
                .clipShape(RoundedRectangle.carely(Radius.r12))
            }
        }
    }
}
