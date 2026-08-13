//
//  ReservationEventResponse.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 07/08/2026.
//


import Foundation

struct ReservationEventResponse: Codable {
    let type: String
    let reservationId: String
    let data: OfferEventData?
    enum CodingKeys: String, CodingKey {
        case type
        case reservationId
        case data
    }
}

struct OfferEventData: Codable {
    let id: String?
}
