//
//  ProfileCoordinatorView.swift
//  EnayaProvider
//
//  Created by AI.
//

import SwiftUI

struct ProfileCoordinatorView: View {
    let container: DIContainer
    @StateObject var coordinator: ProfileCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ProfileView(viewModel: container.makeProfileViewModel(coordinator: coordinator))
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .personalInfo(let profile):
                        ProfilePersonalInfoView(
                            profile: profile,
                            makeEditBioViewModel: { onSuccess in
                                container.makeEditBioViewModel(
                                    profileId: profile.id,
                                    initialBio: profile.bio,
                                    initialSpecialization: profile.specialization,
                                    initialYearsOfExperience: profile.yearsOfExperience,
                                    onSuccess: onSuccess
                                )
                            }
                        )
                    case .documents(let profile):
                        ProfileDocumentsView(
                            profile: profile,
                            viewModel: container.makeProfileViewModel(coordinator: coordinator)
                        )
                    case .reviews(let nurseId, let avgRating, let totalReviews):
                        ProfileReviewsView(
                            viewModel: container.makeProfileReviewsViewModel(nurseId: nurseId),
                            avgRating: avgRating,
                            totalReviews: totalReviews
                        )
                    case .settings:
                        ProfileSettingsView()
                    }
                }
        }
    }
}
