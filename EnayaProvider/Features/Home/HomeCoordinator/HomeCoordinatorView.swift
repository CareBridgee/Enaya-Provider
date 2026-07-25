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

    var body: some View {
        HomeView(viewModel: container.makeHomeViewModel())
    }
}