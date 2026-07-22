//
//  ProfileSetupCoordinatorView.swift
//  Carely
//
//  Created by Mohamed Ayman on 19/07/2026.
//

import SwiftUI

struct ProfileSetupCoordinatorView: View {

    @StateObject private var coordinator: ProfileSetupCoordinator

    private let container: DIContainer
    private let onFinish: () -> Void

    init(container: DIContainer, coordinator: ProfileSetupCoordinator, onFinish: @escaping () -> Void) {
        self.container = container
        self.onFinish = onFinish
        _coordinator = StateObject(wrappedValue: coordinator)
    }

    var body: some View {
        VStack(spacing: Spacing.s16) {

            ProfileSetupHeaderBar(showBack: !coordinator.isFirstStep, onBack: coordinator.previous)

            StepProgressHeader(
                currentStep: coordinator.currentStepIndex,
                totalSteps: ProfileSetupStep.allCases.count,
                stepTitle: coordinator.currentStep.stepTitle
            )
            .padding(.horizontal, Spacing.s16)

            Group {
                switch coordinator.currentStep {
                case .personalInfo:
                    PersonalInfoView(viewModel: container.makePersonalInfoViewModel(coordinator: coordinator))
                case .professionalInfo:
                    ProfessionalInfoView(viewModel: container.makeProfessionalInfoViewModel(coordinator: coordinator))
                case .providedServices:
                    ProvidedServicesView(viewModel: container.makeProvidedServicesViewModel(coordinator: coordinator))
                case .review:
                    ReviewApplicationView(
                        viewModel: container.makeReviewApplicationViewModel(coordinator: coordinator, onSubmitted: onFinish)
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .transition(
                .asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                )
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: coordinator.currentStep)
        }
        .padding(.top, Spacing.s16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.backGround.ignoresSafeArea())
    }
}
