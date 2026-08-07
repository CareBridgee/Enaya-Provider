import Foundation

@MainActor
final class ProfileSetupCoordinator: ObservableObject {

    @Published private(set) var currentStep: ProfileSetupStep
    @Published var data: ProfileSetupData

    init(data: ProfileSetupData, startingStep: ProfileSetupStep = .personalInfo) {
        self.data = data
        self.currentStep = startingStep
    }

    func next() {
        guard let nextStep = currentStep.next else { return }
        currentStep = nextStep
    }

    func previous() {
        guard let previousStep = currentStep.previous else { return }
        currentStep = previousStep
    }

    func go(to step: ProfileSetupStep) {
        currentStep = step
    }

    func save(personalInfo: PersonalInfo) {
        data.personalInfo = personalInfo
    }

    func save(professionalInfo: ProfessionalInfo) {
        data.professionalInfo = professionalInfo
    }

    func save(providedServices: ProvidedServices) {
        data.providedServices = providedServices
    }

    var isFirstStep: Bool { currentStep.isFirst }
    var isLastStep: Bool { currentStep.isLast }

    var currentStepIndex: Int {
        (ProfileSetupStep.allCases.firstIndex(of: currentStep) ?? 0) + 1
    }
}
