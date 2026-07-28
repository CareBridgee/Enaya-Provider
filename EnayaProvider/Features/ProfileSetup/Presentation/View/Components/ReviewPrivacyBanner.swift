import SwiftUI

struct ReviewPrivacyBanner: View {
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.s12) {
            Image(systemName: "checkmark.shield")
                .foregroundColor(.brandPrimary)
                .font(.system(size: IconSize.s20))
            
            Text("Your privacy is our priority. All information is encrypted and will only be used for our verification process. Approval typically takes 24-48 business hours.")
                .carelyText(style: .caption)
                .foregroundColor(.secondaryFont)
                .lineSpacing(3)
        }
        .padding(Spacing.s16)
        .background(Color.surfaceVariant.opacity(0.5))
        .clipShape(RoundedRectangle.carely(Radius.r12))
    }
}