import SwiftUI

struct ProfileContinueFooter: View {
    let title: String
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let onContinue: () -> Void

    var body: some View {
        PrimaryButton(
            title: title,
            icon: "arrow.right",
            iconPosition: .trailing,
            isLoading: isLoading,
            isEnabled: isEnabled,
            action: onContinue
        )
        .padding(.horizontal, Spacing.s16)
        .padding(.top, Spacing.s12)
        .background(Color.backGround)
    }
}