//
//  ProvidedServicesViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import Foundation

@MainActor
final class ProvidedServicesViewModel: ObservableObject {

    @Published var availableServices: [CareService] = []
    @Published var selectedServices: Set<CareService>
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let coordinator: ProfileSetupCoordinator
    private let fetchServiceTypesUseCase: FetchServiceTypesUseCaseProtocol

    init(
        coordinator: ProfileSetupCoordinator,
        fetchServiceTypesUseCase: FetchServiceTypesUseCaseProtocol
    ) {
        self.coordinator = coordinator
        self.fetchServiceTypesUseCase = fetchServiceTypesUseCase
        self.selectedServices = coordinator.data.providedServices.selectedServices
    }
    
    func loadServices() {
        guard availableServices.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let services = try await fetchServiceTypesUseCase.execute()
                self.availableServices = services
                self.coordinator.data.providedServices.availableServices = services
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = "Failed to load services. Please try again."
            }
        }
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
        coordinator.save(providedServices: ProvidedServices(availableServices: availableServices, selectedServices: selectedServices))
    }
}
