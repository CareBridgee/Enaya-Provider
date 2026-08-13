//
//  HomeCoordinatorView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//

import SwiftUI

struct HomeCoordinatorView: View {
    let container: DIContainer
    @ObservedObject var coordinator: HomeCoordinator
    @ObservedObject var viewModel: HomeViewModel
    let onViewAll: () -> Void

    var body: some View {
        HomeView(viewModel: viewModel, onViewAll: onViewAll)
            .fullScreenCover(
                isPresented: Binding(
                    get: { viewModel.acceptedRequestId != nil },
                    set: { isPresented in
                        if !isPresented {
                            viewModel.acceptedRequestId = nil
                        }
                    }
                )
            ) {
                if let reservationId = viewModel.acceptedRequestId {
                    OfferCoordinatorView(
                        container: container,
                        coordinator: container.makeOfferCoordinator(reservationId: reservationId),
                        onFinished: { viewModel.handleOfferFlowFinished(reservationId: reservationId) }
                    )
                }
            }
    }
}
