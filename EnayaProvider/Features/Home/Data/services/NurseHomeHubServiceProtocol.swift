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
    func updateAvailability(isAvailable: Bool, lat: Double, lng: Double)
    func sendHeartbeat()
    func subscribeToReservation(reservationId: String, onEvent: @escaping (ReservationEventResponse) -> Void)
    func unsubscribeFromReservation(reservationId: String)
}

import Foundation

final class NurseHomeSocketDataSource: NurseHomeHubServiceProtocol {
    var onNearbyRequestReceived: ((NearbyNurseServiceRequestResponse) -> Void)?
    
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
        }
        socketClient.onMessageReceivedListeners[listenerKey] = { [weak self] destination, body in
            if destination.contains("/queue/nearby-request") {
                self?.handleIncomingRequest(body: body)
            }
        }
    }
    
    func connect() { socketClient.connect() }
    func disconnect() { unsubscribeFromNearbyRequests() }
    func subscribeToNearbyRequests() { socketClient.subscribe(to: "/user/queue/nearby-request") }
    func unsubscribeFromNearbyRequests() { socketClient.unsubscribe(from: "/user/queue/nearby-request") }

    func updateAvailability(isAvailable: Bool, lat: Double, lng: Double) {
        let payload = AvailabilityRequestDTO(available: isAvailable, lat: isAvailable ? lat : nil, lng: isAvailable ? lng : nil)
        
        if let data = try? encoder.encode(payload), let jsonString = String(data: data, encoding: .utf8) {
            let headers = ["content-type": "application/json"]
            socketClient.send(to: "/app/reservation/availability", headers: headers, body: jsonString)
            print("[Socket] Sent Availability: \(jsonString)")
        }
    }

    func sendHeartbeat() {
        socketClient.send(to: "/app/heartbeat", headers: [:], body: "")
        print("[Socket] Sent Heartbeat")
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
                    print("[Socket] Failed to decode Reservation Event: \(error)")
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
        print("[Socket RAW Body]: \(body)")
        
        guard let data = body.data(using: .utf8) else { return }
        
        do {
            let request = try decoder.decode(NearbyNurseServiceRequestResponse.self, from: data)
            DispatchQueue.main.async { self.onNearbyRequestReceived?(request) }
            print("[Socket] Nearby Request Received: \(request.serviceRequestId)")
        } catch {
            print("[Socket] Failed to decode Nearby Request: \(error)")
        }
    }
}
