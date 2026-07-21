import Foundation

@MainActor
final class UnderReviewViewModel: ObservableObject {
    private let onContactSupport: () -> Void
    private let onBackToLogin: () -> Void

    init(onContactSupport: @escaping () -> Void = {}, onBackToLogin: @escaping () -> Void) {
        self.onContactSupport = onContactSupport
        self.onBackToLogin = onBackToLogin
    }

    func contactSupportTapped() { onContactSupport() }
    func backToLoginTapped() { onBackToLogin() }
}