import SwiftUI

struct ApplicationStatusHeader: View {
    var body: some View {
        HStack {
            Text("CareConnect")
                .carelyText(style: .heading3, weight: .bold)
                .foregroundColor(.brandPrimary)

            Spacer()

            Circle()
                .fill(Color.surfaceVariant)
                .frame(width: Spacing.s32, height: Spacing.s32)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.hint)
                )
        }
        .padding(.top, Spacing.s16)
    }
}