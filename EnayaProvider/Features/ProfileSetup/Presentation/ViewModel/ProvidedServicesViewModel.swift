import Foundation

@MainActor
final class ProvidedServicesViewModel: ObservableObject {

    @Published var selectedServices: Set<CareService>
    @Published var errorMessage: String?

    private let coordinator: ProfileSetupCoordinator

    init(coordinator: ProfileSetupCoordinator) {
        self.coordinator = coordinator
        self.selectedServices = coordinator.data.providedServices.selectedServices
    }

    func toggle(_ service: CareService) {
        if selectedServices.contains(service) {
            selectedServices.remove(service)
        } else {
            selectedServices.insert(service)
        }
    }

    func backTapped() {
        persist()
        coordinator.previous()
    }

    func continueTapped() {
        guard !selectedServices.isEmpty else {
            errorMessage = "Select at least one service you provide."
            return
        }
        errorMessage = nil
        persist()
        coordinator.next()
    }

    private func persist() {
        coordinator.save(providedServices: ProvidedServices(selectedServices: selectedServices))
    }
}