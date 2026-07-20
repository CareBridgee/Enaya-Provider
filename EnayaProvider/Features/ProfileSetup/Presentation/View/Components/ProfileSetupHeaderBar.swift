import SwiftUI

struct ProfileSetupHeaderBar: View {
    let showBack: Bool
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: IconSize.s16, weight: .semibold))
                    .foregroundColor(.primaryFont)
            }
            .frame(width: Spacing.s32, height: Spacing.s32, alignment: .leading)
            .opacity(showBack ? 1 : 0)
            .disabled(!showBack)

            Spacer()

            Text("Registration")
                .carelyText(style: .heading3, weight: .semiBold)
                .foregroundColor(.primaryFont)

            Spacer()

            Spacer().frame(width: Spacing.s32)
        }
    }
}