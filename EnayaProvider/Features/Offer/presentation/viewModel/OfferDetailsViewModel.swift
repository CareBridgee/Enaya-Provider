//
//  OfferDetailsViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation
import UIKit
import MapKit

@MainActor
final class OfferDetailsViewModel: ObservableObject {

    private let coordinator: OfferCoordinator

    init(coordinator: OfferCoordinator) {
        self.coordinator = coordinator
    }

    var offer: ConfirmedOffer { coordinator.offer }

    func copyAddressTapped() {
        UIPasteboard.general.string = offer.address.fullText
    }

    func viewPatientSummaryTapped() {
        // No patient-summary destination yet.
    }

    func openInMapsTapped() {
        let coordinate = CLLocationCoordinate2D(latitude: offer.address.latitude, longitude: offer.address.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = offer.address.line
        mapItem.openInMaps()
    }
}