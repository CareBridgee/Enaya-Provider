//
//  ProfileCoordinatorView.swift
//  EnayaProvider
//
//  Created by AI.
//

import SwiftUI

struct ProfileCoordinatorView: View {
    let container: DIContainer
    let appState: AppState
    @StateObject var coordinator: ProfileCoordinator
    @StateObject private var viewModel: ProfileViewModel

    init(container: DIContainer, appState: AppState, coordinator: ProfileCoordinator) {
        self.container = container
        self.appState = appState
        self._coordinator = StateObject(wrappedValue: coordinator)
        self._viewModel = StateObject(wrappedValue: container.makeProfileViewModel(coordinator: coordinator))
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ProfileView(viewModel: viewModel)
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .personalInfo(let profile):
                        ProfilePersonalInfoView(
                            profile: viewModel.profile ?? profile,
                            makeEditBioViewModel: { onSuccess in
                                container.makeEditBioViewModel(
                                    profileId: (viewModel.profile ?? profile).id,
                                    initialBio: (viewModel.profile ?? profile).bio,
                                    initialSpecialization: (viewModel.profile ?? profile).specialization,
                                    initialYearsOfExperience: (viewModel.profile ?? profile).yearsOfExperience,
                                    onSuccess: onSuccess
                                )
                            },
                            onUpdateProfileImage: { imageData in
                                try await container.uploadProfileImage(profileId: (viewModel.profile ?? profile).id, imageData: imageData)
                            },
                            fetchVisitsCount: {
                                await container.fetchCompletedVisitsCount()
                            },
                            fetchFeaturedReview: {
                                await container.fetchFeaturedReview(nurseId: (viewModel.profile ?? profile).id)
                            }
                        )
                    case .documents(let profile):
                        ProfileDocumentsView(
                            profile: viewModel.profile ?? profile,
                            viewModel: viewModel
                        )
                    case .reviews(let nurseId, _, _):
                        ProfileReviewsView(
                            viewModel: container.makeProfileReviewsViewModel(nurseId: nurseId)
                        )
                    case .settings:
                        ProfileSettingsView(appState: appState)
                    }
                }
        }
    }
}
