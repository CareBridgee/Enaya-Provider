//
//  OfferCoordinatorView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI

struct OfferCoordinatorView: View {
    let container: DIContainer
    @ObservedObject var coordinator: OfferCoordinator
    let onFinished: () -> Void

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            Group {
                switch coordinator.phase {
                case .active:
                    OfferConfirmedView(
                        coordinator: coordinator,
                        viewModel: container.makeOfferConfirmedViewModel(coordinator: coordinator)
                    )
                case .completed:
                    VisitCompletedView(
                        coordinator: coordinator,
                        viewModel: container.makeVisitCompletedViewModel(coordinator: coordinator, onReturnHome: onFinished)
                    )
                }
            }
            .navigationDestination(for: OfferRoute.self) { route in
                switch route {
                case .details:
                    OfferDetailsView(
                        coordinator: coordinator,
                        viewModel: container.makeOfferDetailsViewModel(reservationId: coordinator.reservationId, coordinator: coordinator)
                    )
                }
            }
        }
        .sheet(isPresented: $coordinator.isShowingCancelSheet) {
            CancelOfferView(
                coordinator: coordinator,
                viewModel: container.makeCancelOfferViewModel(
                    reservationId: coordinator.reservationId,
                    serviceName: "Service Request",
                    coordinator: coordinator,
                    onCancelled: onFinished
                )
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}
