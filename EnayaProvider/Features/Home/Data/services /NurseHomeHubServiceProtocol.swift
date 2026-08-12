//
//  NurseHomeHubServiceProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 07/08/2026.
//

import Foundation

protocol NurseHomeHubServiceProtocol {
    var onNearbyRequestReceived: ((NearbyNurseServiceRequestResponse) -> Void)? { get set }
    func connect()
    func disconnect()
    func subscribeToNearbyRequests()
    func unsubscribeFromNearbyRequests()
    func subscribeToErrors(onError: @escaping (SocketErrorPayload) -> Void)
    func unsubscribeFromErrors()
    func updateAvailability(isAvailable: Bool, lat: Double, lng: Double)
    func sendHeartbeat()
    func withdrawOffer(offerId: String)
    func subscribeToReservation(reservationId: String, onEvent: @escaping (ReservationEventResponse) -> Void)
    func unsubscribeFromReservation(reservationId: String)
}

final class NurseHomeSocketDataSource: NurseHomeHubServiceProtocol {
    var onNearbyRequestReceived: ((NearbyNurseServiceRequestResponse) -> Void)?

    private var onErrorReceived: ((SocketErrorPayload) -> Void)?
    private var desiredAvailability: AvailabilityRequestDTO?

    private let socketClient: SocketClientProtocol
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let listenerKey = "NurseHome"

    init(socketClient: SocketClientProtocol) {
        self.socketClient = socketClient
        setupSocketEvents()
    }

    private func setupSocketEvents() {
        socketClient.onConnectedListeners[listenerKey] = { [weak self] in
            self?.subscribeToNearbyRequests()
            self?.resendAvailabilityIfNeeded()
        }

        socketClient.onMessageReceivedListeners[listenerKey] = { [weak self] destination, body in
            if destination.contains("/queue/nearby-request") {
                self?.handleIncomingRequest(body: body)
            } else if destination.contains("/queue/errors") {
                self?.handleIncomingError(body: body)
            }
        }
    }

    func connect() { socketClient.connect() }

    func disconnect() {
        unsubscribeFromNearbyRequests()
        unsubscribeFromErrors()
        desiredAvailability = nil
    }

    func subscribeToNearbyRequests() { socketClient.subscribe(to: "/user/queue/nearby-request") }

    func unsubscribeFromNearbyRequests() { socketClient.unsubscribe(from: "/user/queue/nearby-request") }

    func subscribeToErrors(onError: @escaping (SocketErrorPayload) -> Void) {
        self.onErrorReceived = onError
        socketClient.subscribe(to: "/user/queue/errors")
    }

    func unsubscribeFromErrors() {
        socketClient.unsubscribe(from: "/user/queue/errors")
        self.onErrorReceived = nil
    }

    func updateAvailability(isAvailable: Bool, lat: Double, lng: Double) {
        let payload = AvailabilityRequestDTO(available: isAvailable, lat: isAvailable ? lat : nil, lng: isAvailable ? lng : nil)
        desiredAvailability = isAvailable ? payload : nil
        sendAvailability(payload)
    }

    private func sendAvailability(_ payload: AvailabilityRequestDTO) {
        guard socketClient.isConnected else { return }
        if let data = try? encoder.encode(payload), let jsonString = String(data: data, encoding: .utf8) {
            let headers = ["content-type": "application/json;charset=UTF-8"]
            socketClient.send(to: "/app/reservation/availability", headers: headers, body: jsonString)
        }
    }

    private func resendAvailabilityIfNeeded() {
        guard let payload = desiredAvailability else { return }
        sendAvailability(payload)
    }

    func withdrawOffer(offerId: String) {
        let payload = ["offerId": offerId]
        
        if let data = try? JSONSerialization.data(withJSONObject: payload),
           let jsonString = String(data: data, encoding: .utf8) {
            let headers = ["content-type": "application/json;charset=UTF-8"]
            socketClient.send(to: "/app/reservation/offer/withdraw", headers: headers, body: jsonString)
        }
    }

    func sendHeartbeat() {
        socketClient.send(to: "/app/heartbeat", headers: [:], body: "")
    }

    func subscribeToReservation(reservationId: String, onEvent: @escaping (ReservationEventResponse) -> Void) {
        let destination = "/topic/reservation/\(reservationId)"
        socketClient.subscribe(to: destination)

        let reservationListenerKey = "Reservation_\(reservationId)"
        socketClient.onMessageReceivedListeners[reservationListenerKey] = { [weak self] dest, body in
            if dest == destination {
                guard let self = self, let data = body.data(using: .utf8) else { return }
                do {
                    let event = try self.decoder.decode(ReservationEventResponse.self, from: data)
                    DispatchQueue.main.async {
                        onEvent(event)
                    }
                } catch {
                }
            }
        }
    }

    func unsubscribeFromReservation(reservationId: String) {
        let destination = "/topic/reservation/\(reservationId)"
        socketClient.unsubscribe(from: destination)
        socketClient.onMessageReceivedListeners.removeValue(forKey: "Reservation_\(reservationId)")
    }

    private func handleIncomingRequest(body: String) {
        guard let data = body.data(using: .utf8) else { return }
        do {
            let request = try decoder.decode(NearbyNurseServiceRequestResponse.self, from: data)
            DispatchQueue.main.async { self.onNearbyRequestReceived?(request) }
        } catch {
        }
    }

    private func handleIncomingError(body: String) {
        guard let data = body.data(using: .utf8) else { return }
        do {
            let errorPayload = try decoder.decode(SocketErrorPayload.self, from: data)
            DispatchQueue.main.async { self.onErrorReceived?(errorPayload) }
        } catch {
        }
    }
}
