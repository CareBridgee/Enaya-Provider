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

    func viewPatientSummaryTapped() {}

    func callPatientTapped() {
        guard let phoneNumber = offer.patient.phoneNumber,
              let url = URL(string: "tel://\(phoneNumber)") else { return }
        UIApplication.shared.open(url)
    }

    func openInMapsTapped() {
        let addressText = offer.address.fullText
        guard !addressText.isEmpty else { return }

        CLGeocoder().geocodeAddressString(addressText) { placemarks, _ in
            guard let coordinate = placemarks?.first?.location?.coordinate else { return }
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
            mapItem.name = addressText
            mapItem.openInMaps()
        }
    }
}
