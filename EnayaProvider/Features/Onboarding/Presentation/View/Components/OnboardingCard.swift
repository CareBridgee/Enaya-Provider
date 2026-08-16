import SwiftUI

struct OnboardingCard: View {
    let page: OnboardingPage
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Radius.r24, style: .continuous)
                .fill(Color.surface)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
            
            GeometryReader { geo in
                page.illustration
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.r24, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OnboardingCard(
        page: OnboardingPage(
            id: 0,
            title: "Provide Quality Healthcare",
            description: "Connect with patients in your area.",
            illustration: Image.onboarding1
        )
    )
    .frame(width: 300, height: 380)
}
