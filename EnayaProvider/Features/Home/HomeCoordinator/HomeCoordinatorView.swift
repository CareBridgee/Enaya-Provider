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
    @StateObject private var viewModel: HomeViewModel

    init(container: DIContainer, coordinator: HomeCoordinator) {
        self.container = container
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: container.makeHomeViewModel())
    }

    var body: some View {
        HomeView(viewModel: viewModel)
            .fullScreenCover(item: $viewModel.confirmedOffer) { offer in
                OfferCoordinatorView(
                    container: container,
                    coordinator: container.makeOfferCoordinator(offer: offer),
                    onFinished: { viewModel.confirmedOffer = nil }
                )
            }
    }
}
