//
//  SecurityCard.swift
//  Carely
//
//  Created by Mina on 17/07/2026.
//

import SwiftUI

struct SecurityCard: View {

    var body: some View {

        HStack(spacing: 16) {

            Circle()
                .fill(Color.mintSurface)
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "shield.fill")
                        .foregroundStyle(Color.brandPrimary)
                }

            VStack(alignment: .leading, spacing: 4) {

                Text("secure care")
                    .carelyText(style: .bodyLarge)
                    .foregroundColor(Color.primaryFont)

                Text("Your number is used only for verification and secure coordination of services.")
                    .carelyText(style: .bodySmall)
                    .foregroundStyle(Color.hint)
            }

            Spacer(minLength: 0)
        }
        .padding()
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.06), radius: 10)
    }
}

#Preview {
    SecurityCard()
        .padding()
        .background(Color.backGround)
}
