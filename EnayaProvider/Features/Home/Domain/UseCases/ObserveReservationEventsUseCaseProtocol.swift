//
//  ObserveReservationEventsUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 07/08/2026.
//


import Foundation

protocol ObserveReservationEventsUseCaseProtocol {
    func execute(reservationId: String) -> AsyncStream<ReservationEventResponse>
}

struct ObserveReservationEventsUseCase: ObserveReservationEventsUseCaseProtocol {
    let repository: HomeRepositoryProtocol
    func execute(reservationId: String) -> AsyncStream<ReservationEventResponse> {
        repository.observeReservationEvents(reservationId: reservationId)
    }
}